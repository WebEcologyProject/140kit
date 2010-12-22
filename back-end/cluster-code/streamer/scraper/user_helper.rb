class UserHelper
  
  def self.hash_users(dataset)
    users = []
    dataset.each do |entry|
      user = UserHelper.hash_user(entry)
      users << user
    end
    users = U.uniform_columns(users)
    return {:users => users}
  end
  
  def self.hash_user(raw_user)
    disallowed_keys = ["profile_use_background_image", "follow_request_sent", "show_all_inline_media"]
    user = {}
      user["screen_name"] = raw_user["screen_name"]
      raw_user.delete_if {|k, v| k == "following" || k == "status"}
      raw_user.each_pair do |key, value|
        if key == "id"
          user["twitter_id"] = value
        elsif key == "created_at"
          user["created_at"] = Time.parse(value)
        elsif key == "geo"
          user["geo"] = value["coordinates"].join(", ")
        elsif key == "location"
          user["location"] = value
        else
          user[key] = value if !disallowed_keys.include?(key)
        end
      end
      # puts "Hashed user: #{raw_user["screen_name"]}"
      return user
  end

def pickup_lost_users(metadata_id, metadata_type)
  metadata = metadata_type.classify.constantize.find(:id => metadata_id)
  user_names = Tweet.find_all(:metadata_id => metadata_id, :metadata_type => metadata_type).collect{|x| x.screen_name }.compact.uniq
  users = []
  user_names.each do |user_name|
    url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{user_name}"
    data = U.return_data(url)
    if !data.nil?
      if !data.empty?
        data = JSON.parse(data)
        user = UserHelper.hash_user(data.first["user"])
        user["metadata_id"] = metadata_id
        user["metadata_type"] = metadata_type
        user["scrape_id"] = metadata.scrape.id
        users << user
      end
    end
  end
  Database.save_all(:users => users)
end

end
