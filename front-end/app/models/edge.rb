class Edge < ActiveRecord::Base
  belongs_to :graph
  belongs_to :collection
end
