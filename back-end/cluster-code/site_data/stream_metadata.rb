class StreamMetadata < SiteData
  attr_accessor :id, :finished, :term, :sanitized_term
  attr_accessor :flagged, :instance_id, :researcher_id, :tweets_count, :users_count
  attr_accessor :scrape_id, :branching, :branch_terms, :created_at, :updated_at, :collection_id, :scrape_finished, :collection, :retweets

  ###############Relation methods

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
      @tweets = Tweet.find_all({:metadata_id => @id, :metadata_type => "stream_metadata"})
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
      @users = User.find_all({:metadata_id => @id, :metadata_type => "stream_metadata"})
      return @users
    else
      return @users
    end
  end

end