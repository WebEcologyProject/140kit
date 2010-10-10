class Curation < ActiveRecord::Base
  belongs_to :curation
  has_and_belongs_to_many :datasets
end
