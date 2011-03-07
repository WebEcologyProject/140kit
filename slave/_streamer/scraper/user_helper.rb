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
    # disallowed_keys = ["id_str", "profile_use_background_image", "follow_request_sent", "show_all_inline_media", "mobile_phone_discoverability_set", "email_discoverability_set", "discoverable_by_email", "discoverable_by_mobile_phone"]
    allowed_keys = ["name", "screen_name", "location", "description", "profile_image_url", "url",
                    "protected", "followers_count", "profile_background_color", "profile_text_color",
                    "profile_link_color", "profile_sidebar_fill_color", "profile_sidebar_border_color",
                    "friends_count", "created_at", "favourites_count", "utc_offset", "time_zone",
                    "profile_background_image_url", "profile_background_tile", "notifications",
                    "geo_enabled", "verified", "following", "listed_count", "statuses_count",
                    "contributors_enabled", "lang", "id"]
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
          user[key] = value if allowed_keys.include?(key)
        end
      end
      # puts "Hashed user: #{raw_user["screen_name"]}"
      return user
  end
  
end
