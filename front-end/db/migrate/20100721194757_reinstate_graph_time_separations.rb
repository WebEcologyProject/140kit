class ReinstateGraphTimeSeparations < ActiveRecord::Migration
  def self.up
    add_column :graphs, :date, :integer
  end

  def self.down
    remove_column :graphs, :date
  end
end
