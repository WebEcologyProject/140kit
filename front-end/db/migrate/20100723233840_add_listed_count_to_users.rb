class AddListedCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :listed_count, :integer
  end

  def self.down
    remove_column :users, :listed_count
  end
end
