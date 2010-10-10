class ChangeEndTimeToLength < ActiveRecord::Migration
  def self.up
    rename_column :datasets, :end_time, :length
    change_column :datasets, :length, :integer
  end

  def self.down
    change_column :datasets, :length, :datetime
    rename_column :datasets, :length, :end_time
  end
end
