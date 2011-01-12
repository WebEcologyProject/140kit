class Graphml
  def self.generate_file(query, filename, path="files")#$w.tmp_path)
    @user_names = []
    internal_keys = ["graph_id", "lock", "flagged", "dataset_id", "id"]
    graphml = File.open(path+"/"+filename+".graphml", "w")
    graphml.write(self.graphml_header(Time.now.to_i.to_s))
    edges = Database.spooled_result(query)
    first_edge = edges.fetch_hash.reject{|k,v| internal_keys.include?(k)}
    first_edge["edge_id"] = first_edge["edge_id"].to_i
    graphml.write(self.graphml_attribute_declares(first_edge))
    graphml.write(self.nodes(first_edge))
    graphml.write(self.edge(first_edge))
    while edge = edges.fetch_hash do
      edge = edge.reject{|k,v| internal_keys.include?(k)} if !edge.nil?
      graphml.write(self.nodes(edge))
      graphml.write(self.edge(edge))
    end
    graphml.write(self.graphml_footer)
    graphml.close
    edges.free
    Database.terminate_spooling
  end

  def self.graphml_header(key)
    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \nxsi:schemaLocation=\"http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd\">\n\t<graph 
  id=\"#{key}\" edgedefault=\"directed\">"
  end
  
  def self.graphml_attribute_declares(edge)
    declares = "\t<key id=\"weight\" for=\"edge\" attr.name=\"weight\" attr.type=\"int\"/>\n\t<key id=\"ids\" for=\"edge\" attr.name=\"ids\" attr.type=\"string\"/>\n"
    edge.each_pair do |attribute, value|
      declares += "\t<key id=\"#{attribute}\" for=\"edge\" attr.name=\"#{attribute}\" attr.type=\"#{self.graphml_class(value.class)}\"/>\n"
    end
    return declares
  end
  
  def self.nodes(edge)
    nodes = (edge.values_at("start_node", "end_node")-@user_names).collect{|screen_name| "\n\t\t<node id=\"#{screen_name}\"/>"}.to_s.concat("\n\t\t")
    start_node = edge.values_at("start_node").first
    end_node = edge.values_at("end_node").first
    @user_names << start_node if !@user_names.include?(start_node)
    @user_names << end_node if !@user_names.include?(end_node)
    return nodes
  end
  
  def self.edge(edge)
    edge_data = "<edge id=\"#{edge["edge_id"]}\" source=\"#{edge["start_node"]}\" target=\"#{edge["end_node"]}\">\n"
    edge.each_pair do |k, v|
      edge_data += "\t\t\t<data key=\"#{k}\">#{v}</data>\n"
    end
    edge_data += "\t\t</edge>\n"
    return edge_data
  end
  
  def self.graphml_footer
    return "\t\n</graph>\n</graphml>"
  end
  
  def self.graphml_class(ruby_class)
    case ruby_class.to_s
    when "Fixnum"
      return "int"
    when "Bignum"
      return "double"  
    when "Integer"
      return "int"  
    when "String"
      return "string"
    end
  end
end