class User < ActiveRecord::Base
  has_many :tweets
  belongs_to :scrape
end
