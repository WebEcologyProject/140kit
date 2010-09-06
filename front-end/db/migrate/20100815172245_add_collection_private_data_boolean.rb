class AddCollectionPrivateDataBoolean < ActiveRecord::Migration
  def self.up
    add_column :collections, :private_data, :boolean
  end

  def self.down
    remove_column :collections, :private_data
  end
end
