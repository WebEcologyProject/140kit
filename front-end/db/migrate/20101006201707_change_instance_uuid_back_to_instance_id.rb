class ChangeInstanceUuidBackToInstanceId < ActiveRecord::Migration
  def self.up
    rename_column :instances, :uuid, :instance_id
  end

  def self.down
    rename_column :instances, :instance_id, :uuid
  end
end
