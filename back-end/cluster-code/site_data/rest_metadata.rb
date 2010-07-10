class RestMetadata < SiteData
  attr_accessor :id, :scrape_id, :finished, :flagged, :instance_id, :created_at, :updated_at
  attr_accessor :researcher_id, :collection_id, :tweets_count, :users_count, :collection_type, :source_data, :source_data_type
  
  def scrape
    if @scrape.nil?
      @scrape = Scrape.find({:id => @scrape_id})
      return @scrape
    else
      return @scrape
    end
  end

  def branch_terms
    if @branch_terms.nil?
      @branch_terms = BranchTerm.find_all({:scrape_id => @scrape_id, :stream_metadata_id => @id})
      return @scrape
    else
      return @scrape
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
  
  def tweets
    if @tweets.nil?
      @tweets = Tweet.find_all({:metadata_id => @id, :metadata_type => "rest_metadata"})
      return @tweets
    else
      return @tweets
    end
  end
  
  def retweets
    if @retweets.nil?
      @retweets = Database.result("select * from tweets where metadata_id = #{@id} and in_reply_to_status_id != 0").collect{|t| Tweet.new(t)}
      return @retweets
    else
      return @retweets
    end
  end

  def users
    if @users.nil?
      @users = User.find_all({:metadata_id => @id, :metadata_type => "rest_metadata"})
      return @users
    else
      return @users
    end
  end
end