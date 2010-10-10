class Dataset < ActiveRecord::Base
  has_and_belongs_to_many :curations
  has_many :users
  has_many :tweets
  has_many :analysis_metadatas
end
