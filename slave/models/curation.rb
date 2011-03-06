class Curation
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :researcher_id, Integer
  property :single_dataset, Boolean
  property :analyzed, Boolean
  property :created_at, DateTime
  property :updated_at, DateTime
  has n, :datasets, :through => Resource
end