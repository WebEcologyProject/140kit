class RenameDatasetIdToCurationIdOnAnalysisMetadatas < ActiveRecord::Migration
  def self.up
    rename_column :analysis_metadatas, :dataset_id, :curation_id
  end

  def self.down
    rename_column :analysis_metadatas, :curation_id, :dataset_id
  end
end
