class AddSingleDatasetAndAnalyzedToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :single_dataset, :boolean, :default => false
    add_column :curations, :analyzed, :boolean, :default => false
  end

  def self.down
    remove_column :curations, :single_dataset
    remove_column :curations, :analyzed
  end
end
