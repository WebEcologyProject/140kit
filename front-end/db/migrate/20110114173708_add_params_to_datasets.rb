class AddParamsToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :params, :string
  end

  def self.down
    remove_column :datasets, :params
  end
end
