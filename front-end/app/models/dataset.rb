class Dataset < ActiveRecord::Base
  has_and_belongs_to_many :curations, :join_table => 'curation_datasets'
  has_many :users
  has_many :tweets
end
