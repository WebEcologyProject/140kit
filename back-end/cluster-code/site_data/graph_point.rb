class GraphPoint < SiteData
  attr_accessor :label, :value, :graph_id, :collection_id, :id, :graph, :collection

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
      @graph = Graph.find({:graph_id => @graph_id, :collection_id => @collection_id})
      return @graph
    else
      return @graph
    end
  end
  
end