class User
  include DataMapper::Resource
  property :id, Serial
  property :twitter_id, Integer
  property :name, String
  property :screen_name, String
  property :location, String
  property :description, String
  property :profile_image_url, String
  property :url, String
  property :protected, Boolean
  property :followers_count, Integer
  property :profile_background_color, String
  property :profile_text_color, String
  property :profile_link_color, String
  property :profile_sidebar_fill_color, String
  property :profile_sidebar_border_color, String
  property :friends_count, Integer
  property :created_at, DateTime
  property :favourites_count, Integer
  property :utc_offset, Integer
  property :time_zone, String
  property :profile_background_image_url, String
  property :profile_background_tile, Boolean
  property :notifications, Boolean
  property :geo_enabled, Boolean
  property :verified, Boolean
  property :following, Boolean
  property :statuses_count, Integer
  # property :contributers_enabled, Boolean
  property :lang, String
  property :listed_count, Integer
  property :dataset_id, Integer
end