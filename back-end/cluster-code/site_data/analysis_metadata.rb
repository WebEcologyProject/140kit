class AnalysisMetadata < SiteData
  attr_accessor :function, :instance_id, :collection_id, :finished, :id, :collection, :processing, :scrape_id, :scrape, :rest, :save_path

  ###############Relation methods

  def collection
    if @collection.nil?
      @collection = Collection.find({:id => @collection_id})
      return @collection
    else
      return @collection
    end
  end
  
  def analytical_offering
    if @analytical_offering.nil?
      @analytical_offering = AnalyticalOffering.find({:function => self.function})
      return @analytical_offering
    else
      return @analytical_offering
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