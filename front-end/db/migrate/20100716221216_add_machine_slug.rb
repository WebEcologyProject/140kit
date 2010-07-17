class AddMachineSlug < ActiveRecord::Migration
  def self.up
    add_column :analytical_instances, :slug, :string
    add_column :stream_instances, :slug, :string
    add_column :rest_instances, :slug, :string
  end

  def self.down
    remove_column :analytical_instances, :slug
    remove_column :stream_instances, :slug
    remove_column :rest_instances, :slug
  end
end