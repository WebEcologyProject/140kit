class AddWorkerKilledBoolean < ActiveRecord::Migration
  def self.up
    add_column :analytical_instances, :killed, :boolean
    add_column :stream_instances, :killed, :boolean
    add_column :rest_instances, :killed, :boolean
  end

  def self.down
    remove_column :analytical_instances, :killed
    remove_column :stream_instances, :killed
    remove_column :rest_instances, :killed
  end
end
