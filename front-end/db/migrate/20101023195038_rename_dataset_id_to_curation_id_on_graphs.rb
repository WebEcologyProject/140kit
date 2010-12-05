class RenameDatasetIdToCurationIdOnGraphs < ActiveRecord::Migration
  def self.up
    rename_column :graphs, :dataset_id, :curation_id
  end

  def self.down
    rename_column :graphs, :curation_id, :dataset_id
  end
end
