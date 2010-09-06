class ChangeRoleAccessAnalyticalOffering < ActiveRecord::Migration
  def self.up
    remove_column :analytical_offerings, :access_level
    add_column :analytical_offerings, :access_level, :string
  end

  def self.down
    remove_column :analytical_offerings, :access_level
    add_column :analytical_offerings, :access_level, :integer
  end
end
