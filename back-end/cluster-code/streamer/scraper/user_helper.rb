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
    disallowed_keys = ["profile_use_background_image", "follow_request_sent", "show_all_inline_media", "id_str"]
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
end
