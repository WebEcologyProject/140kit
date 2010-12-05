class Graph < ActiveRecord::Base
  belongs_to :scrape
  belongs_to :collection
  has_many :graph_points
  has_many :edges

###DATA FETCHING
def self.to_google_json(graph, params)
  result = ""
  if graph.written
    result = Rails.cache.fetch(graph.get_cached("graphs", params[:format], params[:logic])) { Graph.fetch_google_json(graph, params)}
    #GSUB to change out reqid for pre-cached data - reqid must match in order for graphs to work.
    return params[:tqx].nil? ? result : result.gsub(/version:0.1,status:'ok',reqId:\d*,table:/, "version:0.1,status:'ok',"+params["tqx"]+",table:")
  else
    return Graph.fetch_google_json(graph, params)
  end      
end

def self.fetch_google_json(graph, params)
  attribute = graph.style+"_"+graph.title
  case attribute
  when "histogram_tweet_location"
    attribute = "Region Reported"
  when "significant_words"
    attribute = "Significant words (words not included in <a href=\"/pages/stop-words\">The stop word list</a>)"
  when "urls"
    attribute = "URLs"
  when "mentions"
    attribute = "User Mentioned"
  end
  header = "google.visualization.Query.setResponse({version:0.1,status:'ok',#{params["tqx"]},table:{cols:[{id:\"#{attribute}\",label:\"#{attribute}\",type:'string'},{id:'Frequency',label:'Frequency',type:'number'}],"
  data_set = header+"rows:["
  reversed_graphs = ["user_favourites_count", "user_followers_count", "user_friends_count", "user_statuses_count"]
  unprocessed_graph_points = reversed_graphs.include?(graph.title) ? graph.graph_points.sort {|x,y| y.label.to_i <=> x.label.to_i } : graph.graph_points.sort {|x,y| y.value <=> x.value }
  processed_graph_points = Graph.data_sort(graph.title, unprocessed_graph_points)
  processed_graph_points.each do |graph_point|
    if reversed_graphs.include?(graph.title)
      data_set = data_set+"{c:[{v:#{graph_point.value}},{v:#{graph_point.label.gsub("\n", "")}}]},"
    else
      data_set = data_set+"{c:[{v:\"#{graph_point.label.gsub("\n", "")}\"},{v:#{graph_point.value}}]},"
    end
  end
  data_set = data_set.chop
  data_set = data_set+"]}})"
end

def self.fetch_rgraph_json(edges, logic_params)
  node_index = {}
  for edge in edges
    edge = edge["edge"] if edge["edge"].class == Edge
    if node_index[edge.end_node].nil?
      node_index[edge.end_node] = {}
      node_index[edge.end_node]["user"] = edge.end_node
      # node_index[edge.end_node]["adjacencies"] = [edge.start_node]
      # tweet = Tweet.find_by_twitter_id(edge.edge_id)
      node_index[edge.end_node]["tweets"] = [{"from" => edge.end_node, "to" => edge.start_node, "id" => edge.edge_id, "time" => edge.time, "relationship" => edge.style}]
    else
      # node_index[edge.end_node]["adjacencies"] << edge.start_node
      # node_index[edge.end_node]["adjacencies"].uniq!
      # tweet = Tweet.find_by_twitter_id(edge.edge_id)
      node_index[edge.end_node]["tweets"] << {"from" => edge.end_node, "to" => edge.start_node, "id" => edge.edge_id, "time" => edge.time, "relationship" => edge.style}
    end
    if node_index[edge.start_node].nil?
      node_index[edge.start_node] = {}
      node_index[edge.start_node]["user"] = edge.start_node
      # node_index[edge.start_node]["adjacencies"] = [edge.end_node]
      # tweet = Tweet.find_by_twitter_id(edge.edge_id)
      node_index[edge.start_node]["tweets"] = [{"from" => edge.end_node, "to" => edge.start_node, "id" => edge.edge_id, "time" => edge.time, "relationship" => edge.style}]
    else
      # node_index[edge.start_node]["adjacencies"] << edge.end_node
      # node_index[edge.start_node]["adjacencies"].uniq!

      node_index[edge.start_node]["tweets"] << {"from" => edge.end_node, "to" => edge.start_node, "id" => edge.edge_id, "time" => edge.time, "relationship" => edge.style}
    end
  end
  json = "["
  nodes = node_index.values.sort{|x,y| y["tweets"].length <=> x["tweets"].length}
  for node in nodes
    json += "{\"id\":\"#{node["user"]}\","
    json += "\"name\":\"#{node["user"]}\","
    json += "\"data\":{\"relation\" : \"<a href=\\\"http://twitter.com/#{node["user"]}\\\" target=\\\"_blank\\\">#{node["user"]}'s profile</a><br /><h4>#{node["user"]} referenced #{node["tweets"].select{|t| t["from"] == node["user"]}.length} tweets, and was referenced by #{node["tweets"].select{|t| t["to"] == node["user"]}.length} tweets</h4>. <a href=\\\"#\\\" onclick=\\\"$('tweets').hide();$('tweets').show()\\\">show them?</a><br /><ul id=\\\"tweets\\\" style=\\\"display:none;\\\">"
    node["tweets"].each do |tweet|
      json+= "<li><a href=\\\"http://www.twitter.com/#{tweet["from"]}\\\" target=\\\"_blank\\\">#{tweet["from"]}</a> #{tweet["relationship"]}ed <a href=\\\"http://www.twitter.com/#{tweet["to"]}\\\">#{tweet["to"]}</a> in a <a href=\\\"http://twitter.com/#{tweet["from"]}/status/#{tweet["id"]}\\\">tweet</a>.</li>"
    end
    json += "</ul>\"},\"adjacencies\": [  "
    for tweet in node["tweets"]
    json+= "{\"nodeTo\": \"#{tweet["from"]}\",\"data\": {\"weight\": \"1\",\"label\": \"#{tweet["method"]}\",\"edge_id\": \"#{tweet["id"]}\",$direction: [\"#{tweet["from"]}\", \"#{tweet["to"]}\"] }},"
    end
    json += "]},"
  end
  json += "]"
  return json
end

def self.fetch_graphml(edges, params)
  graphml = Graph.graphml_header(Time.now.to_i.to_s)
  graphml = graphml+Graph.graphml_attribute_declares(edges.first)
  graphml = graphml+Graph.graphml_write_data(edges)+Graph.graphml_footer
  return graphml
end

###GOOGLE PARSING
  
  def self.data_sort(title, graphs)
    case title
    when "tweet_location"
      graphs.collect{|graph| graph.label = "<a href='http://maps.google.com/maps?q=#{graph.label}' target='_blank'>#{graph.label}</a>"}
      return graphs
    when "tweet_language"
      return graphs
    when "tweet_created_at"
      return self.graph_date_sort(graphs)
    when "tweet_source"
      return graphs      
    when "user_created_at"
      return self.graph_date_sort(graphs)
    when "user_favourites_count"
      return graphs      
    when "user_friends_count"
      return graphs
    when "user_followers_count"
      return graphs
    when "user_time_zone"
      return graphs
    when "user_lang"
      return graphs
    when "user_statuses_count"
      return graphs
    when "user_geo_enabled"
      return graphs
    when "hashtags"
      graphs.collect{|g| g.label = "<a href='http://search.twitter.com/search?q=#{CGI::escape(g.label)}' target='_blank'>#{g.label}</a>"}
      return graphs
    when "mentions"
      graphs.collect{|g| g.label = "<a href='http://twitter.com/#{g.label.gsub("@", "")}' target='_blank'>#{g.label}</a>"}
      return graphs
    when "significant_words"
      return graphs
    when "urls"
      graphs.collect{|g| g.label = "<a href='#{g.label}' target='_blank'>#{g.label}</a>"}
      return graphs
    end
  end
  
  def self.graph_date_sort(graphs)
    sample_graph = graphs.first
    if !sample_graph.label.scan(/\w\w\w \d\d\d\d/).empty?
      #Fake that its the first of the month so that time parsing can sort appropriately based on epoc
      graphs = graphs.sort{|x,y| Time.parse(x.label.dup.insert(4, "01 ")).to_i <=> Time.parse(y.label.dup.insert(4, "01 ")).to_i}
    elsif !sample_graph.label.scan(/\w\w\w \d*, \d\d\d\d, \d*$/).empty?
      graphs = graphs.sort{|x,y| Time.parse(x.label+":00").to_i <=> Time.parse(y.label+":00").to_i}
    else
      graphs = graphs.sort{|x,y| Time.parse(x.label).to_i <=> Time.parse(y.label).to_i}
    end
  end
###JSON PARSING FOR JS RGRAPH

  
###GRAPHML PARSING

  def self.graphml_header(key)
    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \nxsi:schemaLocation=\"http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd\">\n\t<graph 
id=\"#{key}\" edgedefault=\"directed\">"
  end
  
  def self.graphml_attribute_declares(edge)
    declares = "\t<key id=\"weight\" for=\"edge\" attr.name=\"weight\" attr.type=\"int\"/>\n\t<key id=\"ids\" for=\"edge\" attr.name=\"ids\" attr.type=\"string\"/>\n"
    attribute_listing = edge["attributes"]
    if attribute_listing.class == Hash
      attribute_listing.each_pair do |attribute, value|
        declares += "\t<key id=\"#{attribute}\" for=\"edge\" attr.name=\"#{attribute}\" attr.type=\"#{value["class"]}\"/>\n"
      end
    end
    return declares
  end

  def self.graphml_write_data(edges)
    if edges.first.class == Hash
      graph_nodes = edges.collect{|edge| edge["edge"].attributes.values_at("start_node", "end_node")}.flatten.uniq.collect{|screen_name| "\n\t\t<node id=\"#{screen_name}\"/>"}.to_s.concat("\n\t\t")
    else
      graph_nodes = edges.collect{|edge| edge.attributes.values_at("start_node", "end_node")}.flatten.uniq.collect{|screen_name| "\n\t\t<node id=\"#{screen_name}\"/>"}.to_s.concat("\n\t\t")
    end
    weighted_edges = {}
    edges.each do |edge|
      if edge["edge"].class == Edge
        temp_edge = edge["edge"]
      else
        temp_edge = edge
      end
      if weighted_edges[temp_edge.start_node].nil?
        weighted_edges[temp_edge.start_node] = {}
        weighted_edges[temp_edge.start_node][temp_edge.end_node] = {"weight" => 1, "ids" => [temp_edge.edge_id]}
      elsif weighted_edges[temp_edge.start_node][temp_edge.end_node].nil?
        weighted_edges[temp_edge.start_node][temp_edge.end_node] = {"weight" => 1, "ids" => [temp_edge.edge_id]} 
      else 
        weighted_edges[temp_edge.start_node][temp_edge.end_node]["weight"] += 1
        weighted_edges[temp_edge.start_node][temp_edge.end_node]["ids"] << temp_edge.edge_id
      end
      if edge["attributes"].class == Hash
        edge["attributes"].each_pair do |k, v|
          weighted_edges[temp_edge.start_node][temp_edge.end_node][k] = v["value"]
        end
      end
    end
    graph_edges = Graph.graphml_write_edges(weighted_edges)
    return graph_nodes+graph_edges
  end

  def self.graphml_write_edges(edges)
    edge_data = ""
    edges.each_pair do |start_node, end_node_data|
      end_node_data.each_pair do |end_node, data|
        edge_data += "\t\t<edge id=\"#{Time.now.to_i+rand(100000)}\" source=\"#{start_node}\" target=\"#{end_node}\">\n"
        data.each_pair do |k, v|
          if v.class == Array
            v = v.join(",")
          end
          edge_data += "\t\t\t<data key=\"#{k}\">#{v}</data>\n"
        end
        edge_data += "\t\t</edge>\n"
      end
    end
    return edge_data
  end
  
  def self.graphml_footer
    return "\t\n</graph>\n</graphml>"
  end
  
  ###CACHING
  
  def get_cached(graph_prefix, data_type, logic)
    if logic.nil?
      return "#{graph_prefix}_#{self.id}_#{self.title}_#{self.style}_#{data_type}"
    else
      return "#{graph_prefix}_#{self.id}_#{self.title}_#{self.style}_#{data_type}_#{logic.to_s.gsub(/[|:><]/, "_")}"
    end
  end
end