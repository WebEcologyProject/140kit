class AnalyticalInstance < ActiveRecord::Base
  has_many :metadatas, :class_name => "AnalysisMetadata", :primary_key => "instance_id", :foreign_key => "instance_id"
  
  def self.metadata_class
    return AnalysisMetadata
  end
end
