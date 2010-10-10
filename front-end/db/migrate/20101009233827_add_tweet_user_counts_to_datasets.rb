class AddTweetUserCountsToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :tweets_count, :integer
    add_column :datasets, :users_count, :integer
  end

  def self.down
    remove_column :datasets, :tweets_count
    remove_column :datasets, :users_count
  end
end
