class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :twitter_id
      t.string :name
      t.string :screen_name
      t.string :location
      t.string :description
      t.string :profile_image_url
      t.string :url
      t.boolean :protected
      t.integer :followers_count
      t.string :profile_background_color
      t.string :profile_text_color
      t.string :profile_link_color
      t.string :profile_sidebar_fill_color
      t.string :profile_sidebar_border_color
      t.integer :friends_count
      t.datetime :created_at
      t.integer :favourites_count
      t.integer :utc_offset
      t.string :time_zone
      t.string :profile_background_image_url
      t.boolean :profile_background_tile
      t.boolean :notifications
      t.boolean :geo_enabled
      t.boolean :verified
      t.boolean :following
      t.integer :statuses_count
      t.integer :scrape_id
      t.boolean :contributors_enabled
      t.string :lang
      t.integer :metadata_id
    end
  end

  def self.down
    drop_table :users
  end
end
