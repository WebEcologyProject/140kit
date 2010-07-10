class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.integer :twitter_id
      t.datetime :published
      t.string :content
      t.string :source
      t.string :language
      t.integer :user_id
      t.integer :scrape_id
      t.string :screen_name
      t.string :location
      t.string :link
      t.string :in_reply_to_status_id
      t.string :in_reply_to_user_id
      t.string :favorited
      t.string :truncated
      t.string :in_reply_to_screen_name
      t.integer :to_user_id
      t.datetime :created_at
      t.datetime :updated_at
      t.string :lat
      t.string :lon
      t.integer :metadata_id
    end
  end

  def self.down
    drop_table :tweets
  end
end
