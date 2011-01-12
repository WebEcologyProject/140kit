class TweetHelper

  attr_accessor :branch_terms

  def self.hash_tweets(dataset)
    tweets = []
    # puts "Retrieved " + dataset.length.to_s + " new tweets"
    dataset.each do |entry|
      tweet = TweetHelper.hash_tweet(entry)
      tweets << tweet
    end
    tweets = U.uniform_columns(tweets)
    return {:tweets => tweets}
  end

  def self.hash_tweet(entry)
    tweet = TweetHelper.scrape_tweet_attributes(entry)
    # puts "Hashed tweet: #{tweet["twitter_id"]}"
    return tweet
  end
  
  def self.scrape_tweet_attributes(entry)
    allowed_fields = ["lat", "twitter_id", "metadata_id", "dataset_id", "in_reply_to_user_id", "lon", "language", "scrape_id", "favorited", "text", "user_id", "truncated", "source", "screen_name", "created_at", "in_reply_to_screen_name", "location", "id", "in_reply_to_status_id"]
    twitter_id = entry["id"]
    tweet = {}
    entry.delete_if{|k, v| k == "title" || k == "profile_image_url" || k == "from_user_id"}
    entry.flatify.each_pair do |key, value|
      case key
      when "id"
        tweet["twitter_id"] = value
      when "user-lang"
        tweet["language"] = value
      when "coordinates"
        tweet["lat"] = value.is_a?(Array) ? value[1] : value
        tweet["lon"] = value.is_a?(Array) ? value[0] : value
      when "geo-coordinates"
        tweet["lat"] = value.is_a?(Array) ? value[1] : value
        tweet["lon"] = value.is_a?(Array) ? value[0] : value
      when "user-location"
        potential_lat_lon = value.scan(/: (\d*\.\d*|\-\d*\.\d*),(\d*\.\d*|\-\d*\.\d*)/).flatten if !value.nil?
        if !value.nil?
          if !entry["place"].nil?
            if !entry["place"]["full_name"].nil?
              tweet["location"] = entry["place"]["full_name"]
            elsif !entry["place"]["name"].nil?
              tweet["location"] = entry["place"]["name"]
            end
            if !entry["place"]["bounding_box"].nil?
              if !entry["place"]["bounding_box"]["coordinates"].nil?
                tweet["lat"] = entry["place"]["bounding_box"]["coordinates"].first.first.first if tweet["lat"].nil?
                tweet["lon"] = entry["place"]["bounding_box"]["coordinates"].first.first.last if tweet["lon"].nil?
              end
            end
          elsif potential_lat_lon.class == Array
            if potential_lat_lon.length == 2
              if potential_lat_lon.first.class == String
                tweet["lat"] = potential_lat_lon[0] if tweet["lat"].nil?
                tweet["lon"] = potential_lat_lon[1] if tweet["lon"].nil?
                tweet["location"] = value.scan(/^.*:/).first
              end
            else 
              tweet["location"] = value
            end
          else
            tweet["location"] = value
          end
        else tweet["location"] = "Not Reported"
        end
      when "user-screen_name"
        tweet["screen_name"] = value        
      when "created_at"
        tweet["created_at"] = Time.parse(value)
      when "text"
        tweet["text"] = value.gsub("\\", "")
      else
        tweet[key] = value if allowed_fields.include?(key)
      end
    end
    tweet.delete("metadata")
    return tweet
  end
  
  def self.check_for_screen_name(tweet_content)
    replied_names = tweet_content.downcase.scan(/rt @(\w*)/).flatten
    mentioned_names = tweet_content.downcase.scan(/@(\w*)/).flatten
    if !replied_names.empty?
      return replied_names.first
    elsif !mentioned_names.empty?
      return mentioned_names.first
    else return "" 
    end
  end
  
  def self.check_for_branch_terms(tweet_content)
    # branch_terms = TweetHelper.prep_branch_terms(@branch_terms)
    # TweetHelper.check_for_branch_terms(twitter_message)
    tweet_content.scan(/(#\w*)\W/).flatten.each do |tag|
      @branch_terms[tag] = @branch_terms[tag].nil? ? 1 : @branch_terms[tag]+1
    end
  end
  
  def self.prep_branch_terms(branch_terms)
    sql_safe_branch_terms = []
    if branch_terms.keys.length > 1
      branch_terms.each_pair do |k, v|
        branch = {}
        branch["word"] = k
        branch["frequency"] = v
        sql_safe_branch_terms << branch
      end
      return sql_safe_branch_terms
    else
      return nil
    end
  end
  
  def self.collect_screen_names(tweets)
    return tweets.collect {|tweet| tweet.values_at("screen_name")}.flatten.uniq.first
  end
end