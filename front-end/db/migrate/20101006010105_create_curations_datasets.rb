class CreateCurationsDatasets < ActiveRecord::Migration
  def self.up
    create_table :curations_datasets do |t|
      t.integer :curation_id
      t.integer :dataset_id
    end
  end

  def self.down
    drop_table :curations_datasets
  end
end
