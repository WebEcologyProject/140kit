class RemoveOldIndexes < ActiveRecord::Migration
  def self.up
    remove_index :tweets, :name => "metadata_id_type"
    remove_index :tweets, :name => "tweet_metadata_id_scrape_id"
    remove_index :tweets, :name => "tweet_metadata_id"
    remove_index :tweets, :name => "scrape_id"
    remove_index :tweets, :name => "tweets_twitter_id_scrape_id_metadata_id_metadata_type"
    remove_index :tweets, :name => "tweets_twitter_id_scrape_id_metadata_id"
    
    add_index :tweets, [:twitter_id, :dataset_id], :unique => true
    
    remove_index :users, :name => "metadata_id_type"
    remove_index :users, :name => "user_metadata_id_scrape_id"
    remove_index :users, :name => "user_metadata_id"
    remove_index :users, :name => "users_screen_name_scrape_id_metadata_id"
    remove_index :users, :name => "scrape_id"
    
    add_index :users, [:twitter_id], :unique => true
  end

  def self.down
    
    remove_index :tweets, :name => "tweets_twitter_id_dataset_id"
    remove_index :users, :name => "tweets_twitter_id_dataset_id"
    
    add_index "tweets", ["metadata_id", "metadata_type"], :name => "metadata_id_type"
    add_index "tweets", ["metadata_id", "scrape_id"], :name => "tweet_metadata_id_scrape_id"
    add_index "tweets", ["metadata_id"], :name => "tweet_metadata_id"
    add_index "tweets", ["scrape_id"], :name => "scrape_id"
    add_index "tweets", ["twitter_id", "scrape_id", "metadata_id", "metadata_type"], :name => "tweets_twitter_id_scrape_id_metadata_id_metadata_type", :unique => true
    add_index "tweets", ["twitter_id", "scrape_id", "metadata_id"], :name => "tweets_twitter_id_scrape_id_metadata_id", :unique => true

    add_index "users", ["metadata_id", "metadata_type"], :name => "metadata_id_type"
    add_index "users", ["metadata_id", "scrape_id"], :name => "user_metadata_id_scrape_id"
    add_index "users", ["metadata_id"], :name => "user_metadata_id"
    add_index "users", ["metadata_type", "scrape_id", "metadata_id", "screen_name"], :name => "users_screen_name_scrape_id_metadata_id", :unique => true
    add_index "users", ["scrape_id"], :name => "scrape_id"
  end
end
