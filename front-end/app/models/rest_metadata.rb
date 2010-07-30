class RestMetadata < ActiveRecord::Base
  belongs_to :scrape
  has_and_belongs_to_many :collections
  has_many :tweets, :foreign_key => "metadata_id"
  has_many :users, :foreign_key => "metadata_id"
  belongs_to :researcher
  belongs_to :collection
  has_one :instance, :class_name => "RestInstance", :primary_key => "instance_id", :foreign_key => "instance_id"
  
  def term
    return self.collection.name
  end
  
end
