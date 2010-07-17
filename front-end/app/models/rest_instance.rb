class RestInstance < ActiveRecord::Base
  has_many :metadatas, :class_name => "RestMetadata", :primary_key => "instance_id", :foreign_key => "instance_id"
  def self.metadata_class
    return RestMetadata
  end
end
