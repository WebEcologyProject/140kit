class StreamInstance < ActiveRecord::Base
  has_many :metadatas, :class_name => "StreamMetadata", :primary_key => "instance_id", :foreign_key => "instance_id"
  def self.metadata_class
    return StreamMetadata
  end
end
