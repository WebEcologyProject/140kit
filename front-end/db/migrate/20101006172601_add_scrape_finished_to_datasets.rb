class AddScrapeFinishedToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :scrape_finished, :boolean
  end

  def self.down
    remove_column :datasets, :scrape_finished
  end
end
