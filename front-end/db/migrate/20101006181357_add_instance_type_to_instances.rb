class AddInstanceTypeToInstances < ActiveRecord::Migration
  def self.up
    add_column :instances, :instance_type, :string
  end

  def self.down
    remove_column :instances, :instance_type
  end
end
