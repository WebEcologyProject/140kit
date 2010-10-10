class MakeScrapeFinishedDefaultFalse < ActiveRecord::Migration
  def self.up
    change_column :datasets, :scrape_finished, :boolean, :default => false
  end

  def self.down
    change_column :datasets, :scrape_finished, :boolean
  end
end
