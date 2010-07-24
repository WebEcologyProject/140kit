class ChangeOutUniqueGraphIndexing < ActiveRecord::Migration
  def self.up
    remove_index("graphs", "title_style_collection")
    add_index(:graphs, [:title, :style, :collection_id, :time_slice, :year, :month, :date, :hour], :unique => true, :name => "unique_graph")
  end

  def self.down
    add_index(:graphs, [:title, :style, :collection_id], :unique => true, :name => "title_style_collection")
    remove_index("graphs", "unique_graph")
  end
end
