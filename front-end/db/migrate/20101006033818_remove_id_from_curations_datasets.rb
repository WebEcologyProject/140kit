class RemoveIdFromCurationsDatasets < ActiveRecord::Migration
  def self.up
    remove_column :curations_datasets, :id
  end

  def self.down
    add_column :curations_datasets, :id, :integer, :auto_increment => true ## is this right?
  end
end
