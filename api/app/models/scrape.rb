class Scrape < ActiveRecord::Base
  has_many :edges
  has_many :tweets
  has_many :users
  has_many :trends
  has_many :graphs
  has_many :graph_points
  has_many :branch_terms
  belongs_to :researcher
end
