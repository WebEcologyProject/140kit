class AddColumnDatasetIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :dataset_id, :integer
  end

  def self.down
    remove_column :users, :dataset_id
  end
end
