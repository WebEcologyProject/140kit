class AddColumnDatasetIdToTweets < ActiveRecord::Migration
  def self.up
    add_column :tweets, :dataset_id, :integer
  end

  def self.down
    remove_column :tweets, :dataset_id
  end
end
