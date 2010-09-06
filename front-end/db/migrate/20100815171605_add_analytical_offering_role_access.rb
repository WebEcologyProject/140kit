class AddAnalyticalOfferingRoleAccess < ActiveRecord::Migration
  def self.up
    add_column :analytical_offerings, :access_level, :integer
  end

  def self.down
    remove_column :analytical_offerings, :access_level
  end
end
