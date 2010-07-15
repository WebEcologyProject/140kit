class ChangeWorkerKilledBooleanDefaults < ActiveRecord::Migration
  def self.up
    change_column :analytical_instances, :killed, :boolean, :default => false
    change_column :stream_instances, :killed, :boolean, :default => false
    change_column :rest_instances, :killed, :boolean, :default => false
  end

  def self.down
  end
end
