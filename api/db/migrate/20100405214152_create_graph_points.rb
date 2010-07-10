class CreateGraphPoints < ActiveRecord::Migration
  def self.up
    create_table :graph_points do |t|
      t.string :label
      t.integer :graph_id
      t.integer :value
      t.integer :scrape_id
    end
  end

  def self.down
    drop_table :graph_points
  end
end
