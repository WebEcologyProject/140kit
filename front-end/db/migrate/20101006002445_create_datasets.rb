class CreateDatasets < ActiveRecord::Migration
  def self.up
    create_table :datasets do |t|
      t.string :term
      t.string :scrape_type
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :datasets
  end
end
