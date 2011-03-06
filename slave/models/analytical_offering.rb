class AnalyticalOffering
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :description, Text
  property :function, String
  property :rest, Boolean
  property :source_code_link, String
  property :created_by, String
  property :created_by_link, String
  property :enabled, Boolean
  property :save_path, String
  property :access_level, String
end