class AddDatasetIdToAnalysisMetadatas < ActiveRecord::Migration
  def self.up
    add_column :analysis_metadatas, :dataset_id, :integer
  end

  def self.down
    remove_column :analysis_metadatas, :dataset_id
  end
end
