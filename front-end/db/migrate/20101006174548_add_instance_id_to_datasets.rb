class AddInstanceIdToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :instance_id, :string, :limit => 40
  end

  def self.down
    remove_column :datasets, :instance_id
  end
end
