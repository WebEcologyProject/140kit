class AnalysisMetadata < SiteData
  attr_accessor :function, :instance_id, :collection_id, :finished, :id, :collection, :processing, :scrape_id, :scrape, :rest, :save_path, :dataset_id, :dataset

  ###############Relation methods

  def collection
    if @collection.nil?
      @collection = Collection.find({:id => @collection_id})
      return @collection
    else
      return @collection
    end
  end
  
  def dataset
    if @dataset.nil?
      @dataset = Dataset.find({:id => @dataset})
      return @dataset
    else
      return @dataset
    end
  end
  
  # def scrape
  #   if @scrape.nil?
  #     @scrape = Scrape.find({:id => @scrape_id})
  #     return @scrape
  #   else
  #     return @scrape
  #   end
  # end
end