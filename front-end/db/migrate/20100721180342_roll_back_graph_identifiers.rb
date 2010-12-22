class RollBackGraphIdentifiers < ActiveRecord::Migration
  def self.up
#    remove_column :graphs, :day
    remove_column :graphs, :minute
  end

  def self.down
 #   add_column :graphs, :day, :integer
    add_column :graphs, :minute, :integer
  end
end
