class Edge < SiteData
  attr_accessor :graph_id, :start_node, :end_node, :edge_id, :time
  attr_accessor :collection_id, :flagged, :lock, :id, :graph, :style, :collection
  ###############Relation methods

  def collection
    if @collection.nil?
      @collection = Collection.find({:id => @collection_id})
      return @collection
    else
      return @collection
    end
  end

  def graph
    if @graph.nil?
      @graph = Graph.find({:graph_id => @graph_id, :scrape_id => @scrape_id})
      return @graph
    else
      return @graph
    end
  end
    
end