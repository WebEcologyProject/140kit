class CreateScrapes < ActiveRecord::Migration
  def self.up
    create_table :scrapes do |t|
      t.integer :researcher_id
      t.string :name
      t.integer :length
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean :finished
      t.boolean :notified
      t.boolean :scrape_finished
      t.string :folder_name
      t.string :lock
      t.boolean :flagged
      t.string :scrape_type
    end
  end

  def self.down
    drop_table :scrapes
  end
end
