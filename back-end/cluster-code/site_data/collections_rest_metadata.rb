class CollectionsRestMetadata < SiteData
  attr_accessor :id, :collection_id, :rest_metadata_id
  attr_accessor :collection, :metadata


  ###############Relation methods

  def metadata
    if @metadata.nil?
      @metadata = RestMetadata.find({:id => @rest_metadata_id})
      return @metadata
    else
      return @metadata
    end
  end

  def collection
    if @collection.nil?
      @collection = Collection.find({:id => @collection_id})
      return @collection
    else
      return @collection
    end
  end

end