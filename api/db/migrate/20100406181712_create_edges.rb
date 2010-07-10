class CreateEdges < ActiveRecord::Migration
  def self.up
    create_table :edges do |t|
      t.string :start_edge
      t.string :end_edge
      t.integer :graph_id
      t.integer :scrape_id
      t.datetime :time
      t.string :lock
      t.integer :edge_id
      t.boolean :flagg

      t.timestamps
    end
  end

  def self.down
    drop_table :edges
  end
end
