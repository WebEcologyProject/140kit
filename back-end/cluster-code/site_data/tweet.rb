class Tweet < SiteData
  
  attr_accessor :twitter_id, :text, :source, :language, :user_id, :scrape_id
  attr_accessor :screen_name, :location, :in_reply_to_status_id, :in_reply_to_user_id
  attr_accessor :favorited, :truncated, :in_reply_to_screen_name, :id, :instance_id, :flagged
  attr_accessor :created_at, :lat, :lon, :metadata, :metadata_id, :user, :metadata_type

  ###############Specific methods

  def scrape
    if @scrape.nil?
      @scrape = Scrape.find({:id => @scrape_id})
      return @scrape
    else
      return @scrape
    end
  end
  
  def user
    if @user.nil?
      @user = User.find({:twitter_id => @user_id})
      return @user
    else
      return @user
    end
  end

  def metadata
    if @metadata.nil?
      @metadata = @metadata_type.classify.constantize.find(:id => @metadata_id)
      return @metadata
    else
      return @metadata
    end
  end
end