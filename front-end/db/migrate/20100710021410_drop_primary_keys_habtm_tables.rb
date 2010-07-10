class DropPrimaryKeysHabtmTables < ActiveRecord::Migration
  def self.up
    remove_column :collections_stream_metadatas, :id
    remove_column :collections_rest_metadatas, :id
  end

  def self.down
    add_column :collections_stream_metadatas, :id, :integer
    add_column :collections_rest_metadatas, :id, :integer
  end
end
