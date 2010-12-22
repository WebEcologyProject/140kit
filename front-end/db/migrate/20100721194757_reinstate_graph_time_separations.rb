class ReinstateGraphTimeSeparations < ActiveRecord::Migration
  def self.up
    remove_column :graphs, :date
    add_column :graphs, :date, :integer
  end

  def self.down
    remove_column :graphs, :date
    add_column :graphs, :date, :string
  end
end
