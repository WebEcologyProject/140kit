class CreateTrends < ActiveRecord::Migration
  def self.up
    create_table :trends do |t|
      t.string :term
      t.datetime :created_at
      t.datetime :ended_at
      t.integer :tweet_count
      t.integer :scrape_id
    end
  end

  def self.down
    drop_table :trends
  end
end
