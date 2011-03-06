class Tweet
  include DataMapper::Resource
  property :id,           Serial
  property :twitter_id,   Integer
  property :text,         Text
  property :language,     String
  property :user_id,      Integer
  property :screen_name,  String
  property :location,     String
  property :in_reply_to_status_id, Integer
  property :in_reply_to_user_id,   Integer
  property :truncated,    String
  property :in_reply_to_screen_name, String
  property :created_at,   DateTime
  property :lat,          String
  property :lon,          String
  property :dataset_id,   Integer
  property :retweet_count,  Integer
end