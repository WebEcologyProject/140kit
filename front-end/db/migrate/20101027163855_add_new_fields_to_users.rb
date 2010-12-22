class AddNewFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :id_str, :string
  end

  def self.down
    remove_column :users, :id_str
  end
end
