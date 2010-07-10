class GraphPoint < ActiveRecord::Base
  belongs_to :collection
  belongs_to :graph_id
end
