class Dataset
  include DataMapper::Resource
  property :id, Serial
  property :scrape_type, String
  property :start_time, DateTime
  property :length, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :scrape_finished, Boolean
  property :instance_id, String
  property :params, String
  property :tweets_count, Integer
  property :users_count, Integer
  has n, :curations, :through => Resource
end