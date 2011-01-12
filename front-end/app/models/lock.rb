class Lock < ActiveRecord::Base
  validates_uniqueness_of :with_id, :scope => :classname
end