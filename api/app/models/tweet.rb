class Tweet < ActiveRecord::Base
  belongs_to :scrape
  belongs_to :user
end
