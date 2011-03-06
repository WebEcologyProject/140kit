class AnalysisMetadata
  include DataMapper::Resource
  property :id, Serial
  property :function, String
  property :finished, Boolean
  property :rest, Boolean
  property :curation_id, Integer
  property :save_path, String
end