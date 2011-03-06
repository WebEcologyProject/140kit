# ### THIS IS A TWEET ###
# 
# {
#   "coordinates"=>nil, "created_at"=>"Fri Jan 14 05:57:29 +0000 2011", "favorited"=>false, "truncated"=>false, "id_str"=>"25793604714762241", 
#   "in_reply_to_user_id_str"=>nil, "contributors"=>nil, "text"=>"setelah td telfonan, skrg musti ngejelasin shallot lg di sms &gt;&lt;\" lol dri td kmna aja pas d'tlp wkwkw", 
#   "id"=>25793604714762241, "retweet_count"=>0, "in_reply_to_status_id_str"=>nil, "geo"=>nil, "retweeted"=>false, "in_reply_to_user_id"=>nil, 
#   "in_reply_to_status_id"=>nil, "in_reply_to_screen_name"=>nil, "source"=>"web", 
#   
#   
#   "entities"=>{"urls"=>[], "hashtags"=>[], "user_mentions"=>[]},
#   
#   
#   "place"=>{"name"=>"Kelapa Gading", "country_code"=>"", "country"=>"Indonesia", "attributes"=>{}, "url"=>"http://api.twitter.com/1/geo/id/c23a5ae63324c567.json", 
#     "id"=>"c23a5ae63324c567", "bounding_box"=>{"coordinates"=>[[[106.886777, -6.181952], [106.934269, -6.181952], [106.934269, -6.136277], [106.886777, -6.136277]]], "type"=>"Polygon"}, 
#     "full_name"=>"Kelapa Gading, Jakarta Utara", "place_type"=>"city"}, 
#     
#   
  # "user"=>{"profile_background_tile"=>true, "name"=>"Glorya Vitantri", "profile_sidebar_fill_color"=>"f9fcfc", "profile_sidebar_border_color"=>"0ed2f5", 
  #   "location"=>"UT: -6.893552,107.613068", "profile_image_url"=>"http://a0.twimg.com/profile_images/1208894739/DSC00260_normal.JPG", "created_at"=>"Fri Aug 14 05:57:40 +0000 2009", 
  #   "is_translator"=>false, "follow_request_sent"=>nil, "id_str"=>"65575036", "profile_link_color"=>"0dc8f7", "favourites_count"=>12, "contributors_enabled"=>false, 
  #   "url"=>"http://twitter.com/Actorkimbeom", "utc_offset"=>25200, "id"=>65575036, "listed_count"=>28, "profile_use_background_image"=>true, "protected"=>false, 
  #   "profile_text_color"=>"5e676b", "lang"=>"en", "followers_count"=>337, "time_zone"=>"Jakarta", "geo_enabled"=>true, 
  #   "description"=>"im spontanius,,cheerfull,,smart,,\r\nfriendly,,and just wants to make more friends.^^ follow me na.", "verified"=>false, 
  #   "profile_background_color"=>"f5f5f5", "notifications"=>nil, "friends_count"=>149, "profile_background_image_url"=>"http://a0.twimg.com/profile_background_images/145583558/1.jpg", 
  #   "statuses_count"=>13835, "screen_name"=>"Rhylze", "following"=>nil, "show_all_inline_media"=>true}
# }
# 
# ######

class TweetHelper
  
  @@allowed_tweet_fields = Tweet.new.attribute_names.collect {|a| a.to_sym }
  @@allowed_user_fields = User.new.attribute_names.collect {|a| a.to_sym }
  
  def self.prepped_tweet_and_user(json)
    tweet = self.prep_tweet(json)
    user = self.prep_user(json)
    return tweet, user
  end
  
  def self.prep_tweet(json)
    tweet = {}
    json.each do |k,v|
      case k
      when :id
        tweet[:twitter_id] = v
      when :user
        tweet[:user_id] = v[:id]
        tweet[:screen_name] = v[:screen_name]
        tweet[:language] = v[:lang]
      when :place
        tweet[:location] = v[:full_name] if !v.nil?
      when :created_at
        tweet[:created_at] = DateTime.parse(v)
      else
        tweet[k] = v if @@allowed_tweet_fields.include?(k)
      end
    end
    return tweet
  end
  
  def self.prep_user(json)
    user = {}
    json[:user].each do |k,v|
      case k
      when :id
        user[:twitter_id] = v
      else
        user[k] = v if @@allowed_user_fields.include?(k)
      end
    end
    return user
  end
  
  def self.assign_to_dataset(hash, dataset_id)
    hash[dataset_id] = dataset_id
    return hash
  end
  
  # def self.prep_tweet(json)
  #   tweet = {}
  #   json.each do |k,v|
  #     case k
  #     when "id"
  #       tweet["twitter_id"] = v
  #     when "user"
  #       tweet["user_id"] = v["id"]
  #       tweet["screen_name"] = v["screen_name"]
  #     else
  #       tweet[k] = v if @@allowed_tweet_fields.include?(k)
  #     end
  #   end
  #   return tweet
  # end
  # 
  # def self.prep_user(json)
  #   user = {}
  #   json["user"].each do |k,v|
  #     case k
  #     when "id"
  #       user["twitter_id"] = v
  #     else
  #       user[k] = v if @@allowed_user_fields.include?(k)
  #     end
  #   end
  #   return user
  # end
  # 
  # def self.assign_to_dataset(hash, dataset_id)
  #   hash["dataset_id"] = dataset_id
  #   return hash
  # end
  
end

# class TweetHelper
# 
#   attr_accessor :branch_terms
# 
#   def self.hash_tweets(dataset)
#     tweets = []
#     # puts "Retrieved " + dataset.length.to_s + " new tweets"
#     dataset.each do |entry|
#       tweet = TweetHelper.hash_tweet(entry)
#       tweets << tweet
#     end
#     tweets = U.uniform_columns(tweets)
#     return {:tweets => tweets}
#   end
# 
#   def self.hash_tweet(entry)
#     tweet = TweetHelper.scrape_tweet_attributes(entry)
#     # puts "Hashed tweet: #{tweet["twitter_id"]}"
#     return tweet
#   end
#   
#   def self.scrape_tweet_attributes(entry)
#     allowed_fields = ["lat", "twitter_id", "metadata_id", "dataset_id", "in_reply_to_user_id", "lon", "language", "scrape_id", "favorited", "text", "user_id", "truncated", "source", "screen_name", "created_at", "in_reply_to_screen_name", "location", "id", "in_reply_to_status_id"]
#     twitter_id = entry["id"]
#     tweet = {}
#     entry.delete_if{|k, v| k == "title" || k == "profile_image_url" || k == "from_user_id"}
#     entry.flatify.each_pair do |key, value|
#       case key
#       when "id"
#         tweet["twitter_id"] = value
#       when "user-lang"
#         tweet["language"] = value
#       when "coordinates"
#         tweet["lat"] = value.is_a?(Array) ? value[1] : value
#         tweet["lon"] = value.is_a?(Array) ? value[0] : value
#       when "geo-coordinates"
#         tweet["lat"] = value.is_a?(Array) ? value[1] : value
#         tweet["lon"] = value.is_a?(Array) ? value[0] : value
#       when "user-location"
#         potential_lat_lon = value.scan(/: (\d*\.\d*|\-\d*\.\d*),(\d*\.\d*|\-\d*\.\d*)/).flatten if !value.nil?
#         if !value.nil?
#           if !entry["place"].nil?
#             if !entry["place"]["full_name"].nil?
#               tweet["location"] = entry["place"]["full_name"]
#             elsif !entry["place"]["name"].nil?
#               tweet["location"] = entry["place"]["name"]
#             end
#             if !entry["place"]["bounding_box"].nil?
#               if !entry["place"]["bounding_box"]["coordinates"].nil?
#                 tweet["lat"] = entry["place"]["bounding_box"]["coordinates"].first.first.first if tweet["lat"].nil?
#                 tweet["lon"] = entry["place"]["bounding_box"]["coordinates"].first.first.last if tweet["lon"].nil?
#               end
#             end
#           elsif potential_lat_lon.class == Array
#             if potential_lat_lon.length == 2
#               if potential_lat_lon.first.class == String
#                 tweet["lat"] = potential_lat_lon[0] if tweet["lat"].nil?
#                 tweet["lon"] = potential_lat_lon[1] if tweet["lon"].nil?
#                 tweet["location"] = value.scan(/^.*:/).first
#               end
#             else 
#               tweet["location"] = value
#             end
#           else
#             tweet["location"] = value
#           end
#         else tweet["location"] = "Not Reported"
#         end
#       when "user-screen_name"
#         tweet["screen_name"] = value        
#       when "created_at"
#         tweet["created_at"] = Time.parse(value)
#       when "text"
#         tweet["text"] = value.gsub("\\", "")
#       else
#         tweet[key] = value if allowed_fields.include?(key)
#       end
#     end
#     tweet.delete("metadata")
#     return tweet
#   end
#   
#   def self.check_for_screen_name(tweet_content)
#     replied_names = tweet_content.downcase.scan(/rt @(\w*)/).flatten
#     mentioned_names = tweet_content.downcase.scan(/@(\w*)/).flatten
#     if !replied_names.empty?
#       return replied_names.first
#     elsif !mentioned_names.empty?
#       return mentioned_names.first
#     else return "" 
#     end
#   end
#   
#   def self.check_for_branch_terms(tweet_content)
#     # branch_terms = TweetHelper.prep_branch_terms(@branch_terms)
#     # TweetHelper.check_for_branch_terms(twitter_message)
#     tweet_content.scan(/(#\w*)\W/).flatten.each do |tag|
#       @branch_terms[tag] = @branch_terms[tag].nil? ? 1 : @branch_terms[tag]+1
#     end
#   end
#   
#   def self.prep_branch_terms(branch_terms)
#     sql_safe_branch_terms = []
#     if branch_terms.keys.length > 1
#       branch_terms.each_pair do |k, v|
#         branch = {}
#         branch["word"] = k
#         branch["frequency"] = v
#         sql_safe_branch_terms << branch
#       end
#       return sql_safe_branch_terms
#     else
#       return nil
#     end
#   end
#   
#   def self.collect_screen_names(tweets)
#     return tweets.collect {|tweet| tweet.values_at("screen_name")}.flatten.uniq.first
#   end
# end