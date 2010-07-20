class Graph < ActiveRecord::Base
  belongs_to :scrape
  belongs_to :collection
  has_many :graph_points
  has_many :edges

###DATA FETCHING
def self.to_google_json(graph_data, params)
  result = ""
  if graph_data.class == Graph
    result = Rails.cache.read(graph_data.get_cached("graphs", params[:format], params[:logic]))
  else
    graph = Graph.find(graph_data["id"])
    if graph.collection.finished && graph.collection.analyzed
      result = Rails.cache.fetch(graph.get_cached("graphs", params[:format], params[:logic])) { Graph.fetch_google_json(graph_data)}
    else
      return Graph.fetch_google_json(graph_data)
    end      
  end
  #GSUB to change out reqid for pre-cached data - reqid must match in order for graphs to work.
  return result.gsub(/version:0.1,status:'ok',reqId:\d*,table:/, "version:0.1,status:'ok',"+params["tqx"]+",table:")
end

def self.fetch_google_json(graph_data)
  attribute = graph_data["style"]+"_"+graph_data["title"]
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
  header = "google.visualization.Query.setResponse({version:0.1,status:'ok',#{graph_data["reqid"]},table:{cols:[{id:\"#{attribute}\",label:\"#{attribute}\",type:'string'},{id:'Frequency',label:'Frequency',type:'number'}],"
  data_set = header+"rows:["
  graphs = graph_data["results"]
  graphs = Graph.data_sort(graph_data["title"], graphs)
  debugger
  graphs.each do |graph|
    data_set = data_set+"{c:[{v:\"#{graph.label.gsub("\n", "")}\"},{v:#{graph.value}}]},"      
  end
  data_set = data_set.chop
  data_set = data_set+"]}})"
end

def self.to_rgraph_json(graph_data, params)
  if graph_data.class == Graph
    return Rails.cache.read(graph_data.get_cached("networks", params[:format], params[:logic]))
  else
    graph = Graph.find(graph_data.first.graph_id)
    if graph.collection.finished && graph.collection.analyzed
      return Rails.cache.fetch(graph.get_cached("networks", params[:format], params[:logic])) { Graph.fetch_rgraph_json(graph_data, params)}
    else
      return fetch_rgraph_json(graph_data, params[:logic])
    end      
  end
end

def self.fetch_rgraph_json(graph_data, logic_params)
  node_index = {}
  for edge in graph_data
    edge = edge["edge"] if edge["edge"].class == Edge
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
  # if edge["edge"].class == Edge
  #   verbose_index = {}
  #   for edge in edges
  #     
  json = "["
  nodes = node_index.to_a.sort {|x,y| node_index[y[0]].length <=> node_index[x[0]].length }
  for node_and_adjacencies in nodes
    node = node_and_adjacencies[0]
    adjacencies = node_and_adjacencies[1]
    json += "{\"id\":\"#{node}\","
    json += "\"name\":\"#{node}\","
    json += "\"data\":{\"relation\" : \"<a href=\\\"http://twitter.com/#{node}\\\" target=\\\"_blank\\\">#{node}'s profile</a>\"},"
    json += "\"adjacencies\":#{adjacencies.inspect}},"
  end
  json += "]"
  return json
end

def self.to_graphml(graph_data, params)
  if graph_data.class == Graph
    return Rails.cache.read(graph_data.get_cached("networks", params[:format], params[:logic]))
  else
    graph = Graph.find(graph_data.first.graph_id)
    if graph.collection.finished && graph.collection.analyzed
      return Rails.cache.fetch(graph.get_cached("networks", params[:format], params[:logic])) { Graph.fetch_graphml(graph_data)}
    else
      return fetch_graphml(graph_data, params)
    end      
  end
end

def self.fetch_graphml(graph_data)
  graphml = Graph.graphml_header(Time.now.to_i.to_s)
  graphml = graphml+Graph.graphml_attribute_declares(graph_data.first)
  graphml = graphml+Graph.graphml_write_data(graph_data)+Graph.graphml_footer
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
      new_graphs_index = {}
      new_graphs = []
      graphs.collect{|g| new_graphs_index[Time.parse(g.label).to_i] = g}
      return new_graphs_index.keys.sort.collect{|k| new_graphs_index[k]}      
    when "tweet_source"
      return graphs      
    when "user_created_at"
      new_graphs_index = {}
      new_graphs = []
      graphs.collect{|g| new_graphs_index[Time.parse(g.label).to_i] = g}
      return new_graphs_index.keys.sort.collect{|k| new_graphs_index[k]}
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