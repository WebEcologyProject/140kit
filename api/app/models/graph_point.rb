class GraphPoint < ActiveRecord::Base
  belongs_to :scrape
  belongs_to :graph
end
