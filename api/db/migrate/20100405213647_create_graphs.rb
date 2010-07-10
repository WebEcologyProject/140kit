class CreateGraphs < ActiveRecord::Migration
  def self.up
    create_table :graphs do |t|
      t.string :title
      t.string :format
      t.integer :scrape_id
      t.string :hour
      t.string :minute
      t.string :date
      t.boolean :written
      t.string :lock
      t.string :flagged
    end
  end

  def self.down
    drop_table :graphs
  end
end
