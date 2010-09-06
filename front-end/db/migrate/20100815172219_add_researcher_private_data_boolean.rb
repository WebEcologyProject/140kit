class AddResearcherPrivateDataBoolean < ActiveRecord::Migration
  def self.up
    add_column :researchers, :private_data, :boolean
  end

  def self.down
    remove_column :researchers, :private_data
  end
end
