# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def stats
    @stats = {}
    @stats["online"] = "Of course. That's how the internet works."
    @stats["requested_at"] = Time.now
    @stats["total_tweets"] = ActiveRecord::Base.connection.execute("explain select count(id) from tweets").all_hashes.first["rows"]
    @stats["total_users"] = ActiveRecord::Base.connection.execute("explain select count(id) from users").all_hashes.first["rows"]
    @stats["number_collections"] = ActiveRecord::Base.connection.execute("select count(id) from collections").fetch_row.first
    @stats["researchers_active"] = ActiveRecord::Base.connection.execute("select count(id) from researchers").fetch_row.first
    @stats["scrape_count"] = ActiveRecord::Base.connection.execute("select count(id) from scrapes").fetch_row.first
    @stats["datasets_count"] = ActiveRecord::Base.connection.execute("select count(id) from collections where single_dataset = 1").fetch_row.first
    @stats["analysis_jobs_completed"] = ActiveRecord::Base.connection.execute("select count(id) from analysis_metadatas").fetch_row.first
    @stats["total_graphs"] = ActiveRecord::Base.connection.execute("select count(id) from graphs").all_hashes.first["rows"]
    @stats["total_graph_points"] = ActiveRecord::Base.connection.execute("select count(id) from graph_points").all_hashes.first["rows"]
    @stats["total_edges"] = ActiveRecord::Base.connection.execute("select count(id) from edges").fetch_row.first
    respond_to do |format|
      format.xml  { render :xml => @stats.to_xml }
      format.json  { render :json => @stats.to_json }
    end
  end
  
  def relational_query
    group = {}
    (params.keys-["action", "controller", "sub_controller", "format"]).collect{|p| group[p] = params[p]}
    statement = []
    group.each_pair {|k,v| statement << "#{k} = '#{v}'"}
    filter_statement = "select * from #{params["sub_controller"]} where #{statement.join(" and ")};"
    results = get_result(filter_statement, params["sub_controller"].camelize.chop.constantize)
    return results
  end
  
  def graph_query(params)
    graph = Graph.find(:first, :conditions => {:collection_id => params["collection_id"].to_i, :style => params["style"], :title => params["title"]})
    if Rails.cache.read(graph.get_cached("graphs", params["format"], params["logic"])).nil?
      params["graph_id"] = graph.id
      return fetch_graph_query(params)
    else
      return graph
    end
  end
  
  def fetch_graph_query(params)
    params["controller"] = "graph_points"
    reqid = params.delete("tqx")
    if params["logic"].class == String
      params["logic"] = params["logic"]+"|graph_id:#{params["graph_id"]}"
    else
      params["logic"] = "graph_id:#{params["graph_id"]}"
    end
    style = params.delete("style")
    title = params.delete("title")
    format = params.delete("format")
    logic_results = logic_parse(params)
    results = get_result(logic_results[0]+" order by value desc", logic_results[1])
    format = format.class == String ? params["format"] = format : params["format"] = nil
    return {"results" => results, "format" => format, "style" => style, "title" => title, "reqid" => reqid, "id" => params["graph_id"]}
  end
  
  def network_query(params)
    graph = Graph.find(:first, :conditions => {:collection_id => params["collection_id"], :style => params["style"].singularize})
    if graph.written
      return Rails.cache.fetch(graph.get_cached("networks", params["format"], params["logic"])) { fetch_network_query(graph, params) }
    else
      return fetch_network_query(graph, params)
    end
  end
  
  def fetch_network_query(graph, params)
    params["controller"] = "edges"
    style = params.delete("style").singularize
    if params["logic"].class == String
      logic = hash_logic(params)
      verbosity = logic["verbose"].to_s == "true" ? true : false
      conn_comp = logic["conn_comp"].nil? ? nil : logic["conn_comp"].first.to_i
      params["logic"] = params["logic"].gsub(/verbose:(\w*)/, "")
      params["logic"] = params["logic"].gsub(/conn_comp:(\d*)/, "")
    end
    logic_results = logic_parse(params)
    results = get_result(logic_results[0], logic_results[1])
    if !conn_comp.nil?
      results = connected_component(results, conn_comp)
    end
    if verbosity
      case style
      when "retweet"
        results = retweet_verboser(results)
      end
    end
    case params["format"]
    when "json"
      return Graph.fetch_rgraph_json(results, params)
    when "graphml"
      return Graph.fetch_graphml(results, params)
    end
  end
  
  def user_network_query(params)
    params["controller"] = "edges"
    if params["logic"].class == String
      start_node = params.delete("start_node")
      if params["logic"].include?("verbose")
        verbosity = hash_logic(params)["verbose"].to_s == "true" ? true : false
        params["logic"] = params["logic"].gsub(/verbose:(\w*)/, "")
      else verbosity = false
      end
      if params["logic"].include?("degrees")
        degrees = hash_logic(params)["degrees"].to_s.to_i
        params["logic"] = params["logic"].gsub(/degrees:(\w*)/, "")
      end
      if params["logic"].include?("directed")
        directed = hash_logic(params)["directed"].to_s == "true" ? true : false
        if directed
          params["logic"] = params["logic"].concat("|start_node:#{start_node}")
        else
          params["logic"] = params["logic"].concat("|start_node,end_node:#{start_node}")
        end
        params["logic"] = params["logic"].gsub(/directed:(\w*)/, "")
      else 
        params["logic"] = params["logic"].concat("|start_node,end_node:#{start_node}")
        directed = false
      end
    end
    logic_results = logic_parse(params)
    edges = get_result(logic_results[0], logic_results[1])
    params["logic"] = params["logic"].gsub(/start_node,end_node:(\w*)/, "").gsub(/end_node,start_node:(\w*)/, "").gsub(/start_node:(\w*)/, "").gsub(/end_node:(\w*)/, "")
    results = degree_branch(edges, params, degrees, directed)
    if verbosity
      case params["style"]
      when "retweets"
        results = retweet_verboser(results)
      end
    else
      return results
    end
  end  
  
  def degree_branch(edges, params, degrees, directed)
    original_degrees = degrees
    total_edges = []
    edges.each do |edge|
      total_edge_ids = total_edges.collect{|ed| ed.edge_id}
      total_edges << edge if !total_edge_ids.include?(edge.edge_id)
    end
    while degrees > 0
      new_params = params.dup
      new_params.delete("start_node")
      if !edges.empty?
        if directed
          names = edges.collect{|edge| edge.end_node }.uniq.join(",")
          new_params["logic"] = new_params["logic"]+"|start_node:"+names
        else
          names = edges.collect{|edge| edge.end_node }.uniq.join(",")
          names += ","+edges.collect{|edge| edge.start_node }.uniq.join(",")
          new_params["logic"] = new_params["logic"]+"|start_node,end_node:"+names
        end
        logic_results = logic_parse(new_params)
        edges = get_result(logic_results[0], logic_results[1])
        edges.each do |edge|
          total_edge_ids = total_edges.collect{|ed| ed.edge_id}
          total_edges << edge if !total_edge_ids.include?(edge.edge_id)
        end
      end
      degrees -= 1
    end
    total_edges = total_edges.flatten.uniq
  end
  
  def connected_component(results, index)
    node_index = {}
    for edge in results
      if node_index[edge.start_node].nil?
        node_index[edge.start_node] = [edge.end_node]
      else
        node_index[edge.start_node] << edge.end_node
        node_index[edge.start_node].uniq!
      end
      if node_index[edge.end_node].nil?
        node_index[edge.end_node] = [edge.start_node]
      else
        node_index[edge.end_node] << edge.start_node
        node_index[edge.end_node].uniq!
      end
    end
    components = []
    temp_node_index = node_index.clone
    temp_node_index.each do |k,v|
      component = [k]
      nodes_to_check = v
      while nodes_to_check.length > 0
        for node in nodes_to_check
          nodes_to_check += node_index[node]
          component << node
        end
        nodes_to_check = (nodes_to_check - component).uniq
      end
      components << component
      component.each {|n| temp_node_index.delete(n)}
    end
    cc_nodes = components.sort {|x,y| y.length <=> x.length }[index].sort {|x,y| y.length <=> x.length }
    cc = results.select {|e| (cc_nodes.include? e.start_node) || (cc_nodes.include? e.end_node) }
    return cc
  end
  
  def retweet_verboser(results)
    new_results = []
    twitter_ids = results.collect {|r| r.edge_id}.uniq.compact
    if !twitter_ids.empty?
      statement = "select * from tweets where"
      twitter_ids.collect {|r| statement += " twitter_id = #{r} or"}
      statement = statement.chop.chop.chop + ";"
      tweets = get_result(statement, Tweet)
      tweet_key = {}
      tweets.collect{|t| tweet_key[t.twitter_id] = {"text" => {"class" => "string", "value" => CGI.escapeHTML(CGI.unescapeHTML(t.text))}, "language" => {"class" => "string", "value" => t.language}, "created_at" => {"class" => "string", "value" => t.created_at}}}
      results.each do |r|
        edge_hash = {}
        edge_hash["edge"] = r
        edge_hash["attributes"] = tweet_key[r.edge_id]
        new_results << edge_hash
      end
    end
    return new_results
  end
  
  def interpret_request(params)
    if !params.keys.include?("logic") || params["logic"].empty?
      group = {}
      (params.keys-["action", "controller", "format"]).collect{|p| group[p] = params[p]}
      statement = []
      group.each_pair {|k,v| statement << "#{k} = #{v}"}
      filter = statement.empty? ? "" : " where #{statement.join(" and ")}"
      filter_statement = "select * from #{params["controller"]} #{filter};"
      return get_result(filter_statement, params["controller"].camelize.chop.constantize)
    else
      logic_results = logic_parse(params)
      return get_result(logic_results[0], logic_results[1])
    end
  end
  
  def logic_parse(params)
    logic = params.keys.include?("logic") ? hash_logic(params) : {}
    attributes = logic.keys.include?("attributes") ? hash_logic(params)["attributes"].join(",") : "*"
    model = params["controller"].camelize.chop
    limit = logic.keys.include?("limit") ? " limit #{hash_logic(params)["limit"]}" : ""
    logical_filter = params.keys.include?("logic") ? set_logical_filter(params["logic"]) : ""
    basic_filter = set_basic_filter(params)
    basic_filter = basic_filter.scan(/\s\w*\s(.*)/)[0][0] if logical_filter.empty? && !basic_filter.empty?
    time_filter = set_time_filter(logic, model)
    time_filter = time_filter.scan(/\s\w*\s(.*)/)[0][0] if logical_filter.empty? && basic_filter.empty? && !time_filter.empty?
    filter_statement = logical_filter+basic_filter+time_filter
    filter_statement = filter_statement.strip.empty? ? filter_statement : " where #{filter_statement}"
    return "select #{attributes} from #{params["controller"]} #{filter_statement} #{limit}", model.constantize
  end

  def set_basic_filter(params)
    basic_filter = " and "
    basic_keys = params.keys-["logic","action","controller","format"]
    basic_keys.each do |k|
      basic_filter = basic_filter+"#{k} = #{prep_parameter(params[k])} and "
    end
    return basic_filter.chop.chop.chop.chop.chop
  end
  
  def hash_logic(params)
    logic = {}
    params["logic"].downcase.gsub(/\|+/, "|").gsub("\"", "").split("|").collect{|k| k.split(":").collect{|v| v.split(",")}}.collect{|k| logic[k[0].to_s] = k[1]}
    return logic
  end
  
  def set_logical_filter(logic)
    reserved_keys = ["attributes", "start", "end", "limit"]
    logical_filter = ""
    logical_groups = logic.split("|").collect{|pairs| pairs.split(":")}
    logical_groups.each do |group|
      if !group.empty? && !group.nil?
        temp_value = ""
        temp_keys = []
        temp_values = []
        if !reserved_keys.include?(group[0])
          if group[0].include?(",")
            group[0].split(",").collect{|key| temp_keys << " or "+key}
            if group[1].include?(",")
              group[1].split(",").collect{|value| temp_values << value}
              temp_keys.each do |k|
                temp_values.each do |v|
                  temp_value = temp_value+k+prep_var(v)
                end
              end
              temp_value = temp_value.gsub(/^ or /, " and (")+")"
            else
              temp_keys.collect{|k| temp_value = temp_value+k+prep_var(group[1])}
              temp_value = temp_value.gsub(/^ or /, " and (")+")"
            end
          else
            if group[1].include?(",")
              group[1].split(",").collect{|v| temp_value = temp_value+" or "+group[0]+prep_var(v)}
              temp_value = temp_value.gsub(/^ or /, " and (")+")"
            else
              temp_value = " and #{group[0]} #{prep_var(group[1])}"
            end
          end
          logical_filter = logical_filter+temp_value
        end
      end
    end
    logical_filter = logical_filter.empty? ? "" : logical_filter.scan(/\s\w*\s(.*)/)[0][0]
    return logical_filter
  end
  
  def get_result(query, model)
    puts query
    results = []
    query_result = ActiveRecord::Base.connection.execute(query+";")
    while row = query_result.fetch_hash do
      results << type_attributes(row, model)
    end
    return results
  end
  
  def type_attributes(row, model)
    return model.new(row)
  end
  
  def set_query(params, logic)
    params.delete("logic") if params.keys.include?("logic")
    params.delete("action") if params.keys.include?("action")
    attributes = !logic.keys.include?("attributes") ? "*" : logic.delete("attributes").join(",")
    model = !params.keys.include?("controller") ? "" : params.delete("controller")
    limit = !logic.keys.include?("attributes") ? nil : "limit #{logic.delete("limit")}"
    return params, attributes, model, limit, logic
  end
  
  def set_time_filter(logic, model)
    case model
    when Tweet.to_s
      time_attribute = "created_at"
    when User.to_s
      time_attribute = "created_at"
    when Graph.to_s
      time_attribute = "time_slice"
    when GraphPoint.to_s
      time_attribute = ""
    when Edge.to_s
      time_attribute = "time"
    when Trend.to_s
      time_attribute = "created_at"
    when Researcher.to_s
      time_attribute = "created_at"
    when Scrape.to_s
      time_attribute = "created_at"
    when BranchTerm.to_s
      time_attribute = ""
    end
    st = logic.keys.include?("start") ? Time.at(logic.delete("start").to_s.to_i).strftime("%Y-%m-%d %H:%M:%S") : nil
    en = logic.keys.include?("end") ? Time.at(logic.delete("end").to_s.to_i).strftime("%Y-%m-%d %H:%M:%S") : nil
    time_window = ""
    if !st.nil? && !en.nil?
      time_window = " and time(#{time_attribute}) between '#{en}' and '#{st}' "
    elsif !st.nil? && en.nil?
      time_window = " and time(#{time_attribute}) <= '#{st}' "
    elsif st.nil? && !en.nil?
      time_window = " and time(#{time_attribute}) >= '#{en}' "
    else time_window = ""
    end
    return time_window
  end
  
  def return_vars(logic)
    final_filter = {}
    filter_statement = ""
    logic.each_pair do |k,v|
      prep_var(v)
      filter_statement = filter_statement+"#{k}#{v} and "
    end
    return final_filter, filter_statement
  end
  
  def prep_var(var)
    var = prep_parameter(var)
    if var.include?(">")
      var = "#{var.gsub(">", "").insert(0, " >= ")}"
    elsif var.include?("<")
      var = "#{var.gsub("<", "").insert(0, " >= ")}"
    elsif var.include?("*")
      var = "#{var.gsub("*", "%").insert(0, " like ")}"
    else var = "#{var.insert(0, " = ")}"
    end
  end
  
  def prep_parameter(parameter)
    if parameter.class == Fixnum || parameter.class == Integer || parameter.class == Float
      return "'#{parameter}'"
    elsif parameter.class == String
      return "'#{parameter}'"
    elsif parameter.class == TrueClass
      return "1"
    elsif parameter.class == FalseClass
      return "0"
    else return parameter
    end
  end
  
end
