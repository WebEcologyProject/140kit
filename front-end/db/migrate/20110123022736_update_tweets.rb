class UpdateTweets < ActiveRecord::Migration
  def self.up
    remove_column :tweets, :scrape_id
    remove_column :tweets, :favorited
    remove_column :tweets, :metadata_id
    remove_column :tweets, :metadata_type
    remove_column :tweets, :instance_id
    remove_column :users, :scrape_id
    remove_column :users, :metadata_id
    remove_column :users, :metadata_type
    remove_column :users, :instance_id
    add_column :tweets, :retweet_count, :integer
  end

  def self.down
  end
end
