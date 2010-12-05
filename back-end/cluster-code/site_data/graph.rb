class Graph < SiteData
  attr_accessor :title, :format, :collection_id, :style, :hour, :date, :month, :year#, :minute, :hour, :day, :month, :year
  attr_accessor :written, :lock, :flagged, :id, :edges, :graph_points, :time_slice, :collection, :curation_id, :curation
  ###############Relation methods

  def collection
    if @collection.nil?
      @collection = Collection.find({:id => @collection_id})
      return @collection
    else
      return @collection
    end
  end
  
  def curation
    if @curation.nil?
      @curation = Curation.find({:id => @curation_id})
      return @curation
    else
      return @curation
    end
  end

  def graph_points
    if @graph_points.nil?
      @graph_points = GraphPoint.find_all({:graph_id => @id, :collection_id => @collection_id})
      return @graph_points
    else
      return @graph_points
    end
  end

  def edges
    if @edges.nil?
      @edges = Edge.find_all({:graph_id => @id, :collection_id => @collection_id})
      return @edges
    else
      return @edges
    end
  end
  
end