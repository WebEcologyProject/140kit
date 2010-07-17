class AnalysisMetadata < ActiveRecord::Base
  belongs_to :collection
  has_one :instance, :class_name => "AnalyticalInstance", :primary_key => "instance_id", :foreign_key => "instance_id"
end
