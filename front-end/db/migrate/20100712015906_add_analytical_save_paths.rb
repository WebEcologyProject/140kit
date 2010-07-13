class AddAnalyticalSavePaths < ActiveRecord::Migration
  def self.up
    add_column :analytical_offerings, :save_path, :string
    add_column :analysis_metadatas, :save_path, :string
  end

  def self.down
    remove_column :analytical_offerings, :save_path, :string
    remove_column :analysis_metadatas, :save_path, :string
  end
end
