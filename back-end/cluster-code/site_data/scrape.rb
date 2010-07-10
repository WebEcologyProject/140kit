class Scrape < SiteData
  attr_accessor :id, :researcher_id, :length, :created_at, :scrape_finished, :name, :humanized_length, :primary_collection_id
  attr_accessor :updated_at, :finished, :notified, :folder_name, :instance_id, :flagged, :scrape_type, :run_ends
  attr_accessor :metadatas, :tweets, :users, :edges, :graph_points, :collection, :researcher
  attr_accessor :scrapes, :pending_email, :branching, :last_branch_check, :ref_data
  
  ###############Relation methods

  def metadatas
    if @metadatas.nil?
      case @scrape_type.downcase
      when 'search'
        @metadatas = StreamMetadata.find_all({:scrape_id => @id})
        return @metadatas
      when 'trend'
        @metadatas = StreamMetadata.find_all({:scrape_id => @id})
        return @metadatas
      when 'network'
        @metadatas = NetworkMetadata.find({:scrape_id => @id})
        return @metadatas
      when 'user source scrape'
        @metadatas = RestMetadata.find_all({:scrape_id => @id})
        return @metadatas
      end
    else
      return @metadatas
    end
  end
  
  def researcher
    if @researcher.nil?
      @researcher = Researcher.find({:id => @researcher_id})
    else
      return @researcher
    end
  end
  #THIS NEEDS TO BE DONE DIFFERENTLY
  def collection
    @collection = Collection.find({:id => @primary_collection_id})
    return @collection
  end
  
  def tweets
    if @tweets.nil?
      @tweets = Tweet.find_all({:scrape_id => @id})
    else
      return @tweets
    end
  end

  def users
    if @users.nil?
      @users = User.find_all({:scrape_id => @id})
    else
      return @users
    end
  end

end