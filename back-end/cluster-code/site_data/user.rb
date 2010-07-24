class User < SiteData
  attr_accessor :twitter_id, :name, :screen_name, :location, :description 
  attr_accessor :profile_image_url, :url, :protected, :followers_count, :metadata_type
  attr_accessor :profile_background_color, :profile_text_color, :profile_link_color, :instance_id, :flagged
  attr_accessor :profile_sidebar_fill_color, :profile_sidebar_border_color, :friends_count
  attr_accessor :created_at, :favourites_count, :utc_offset, :time_zone, :profile_background_image_url
  attr_accessor :profile_background_tile, :notifications, :geo_enabled, :verified, :following, :listed_count
  attr_accessor :statuses_count, :scrape_id, :contributors_enabled, :lang, :id, :metadata_id, :tweets


  ###############Relation methods
  
  def scrape
    if @scrape.nil?
      @scrape = Scrape.find({:id => @scrape_id})
      return @scrape
    else
      return @scrape
    end
  end
  
  def tweets
    if @tweets.nil?
      @tweets = Tweet.find_all({:screen_name => @screen_name})
      return @tweets
    else
      return @tweets
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