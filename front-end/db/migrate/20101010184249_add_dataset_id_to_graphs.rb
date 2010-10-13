class AddDatasetIdToGraphs < ActiveRecord::Migration
  def self.up
    add_column :graphs, :dataset_id, :integer
  end

  def self.down
    remove_column :graphs, :dataset_id
  end
end
