class RenameCurationsDatasetsJoinTable < ActiveRecord::Migration
  def self.up
    rename_table :curations_datasets, :curation_datasets
  end

  def self.down
    rename_table :curation_datasets, :curations_datasets
  end
end
