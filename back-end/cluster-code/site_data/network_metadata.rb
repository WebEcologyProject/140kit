class NetworkMetadata < SiteData
  attr_accessor :network_type, :degree_separation, :current_degree, :finished
  attr_accessor :previous_priority, :current_priority, :scrape_id, :id

  ###############Relation methods

  def scrape
    if @scrape.nil?
      @scrape = Scrape.find({:id => @scrape_id})
      return @scrape
    else
      return @scrape
    end
  end

end