# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100405214859) do

  create_table "branch_terms", :force => true do |t|
    t.string  "word"
    t.integer "frequency"
    t.integer "scrape_id"
    t.integer "metadata_id"
    t.string  "instance_id"
  end
  
  create_table "edges", :force => true do |t|
    t.integer  "edge_id"
    t.integer  "graph_id"
    t.integer  "start_node"
    t.integer  "end_node"
    t.datetime "time"
    t.integer  "scrape_id"
    t.boolean  "flagged"
    t.boolean  "locked"
    t.string   "style"
  end

  create_table "graph_points", :force => true do |t|
    t.string  "label"
    t.integer "graph_id"
    t.integer "value"
    t.integer "scrape_id"
  end

  create_table "graphs", :force => true do |t|
    t.string  "title"
    t.string  "format"
    t.integer "scrape_id"
    t.string  "hour"
    t.string  "minute"
    t.string  "date"
    t.boolean "written"
    t.string  "lock"
    t.string  "flagged"
  end

  create_table "researchers", :force => true do |t|
    t.string   "user_name"
    t.string   "email"
    t.string   "pass_hash"
    t.string   "pass_hash_confirm"
    t.datetime "join_date"
    t.string   "last_login"
    t.string   "account"
    t.datetime "last_access"
    t.string   "info"
    t.string   "avatar"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scrapes", :force => true do |t|
    t.integer  "researcher_id"
    t.string   "name"
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "finished"
    t.boolean  "notified"
    t.boolean  "scrape_finished"
    t.string   "folder_name"
    t.string   "lock"
    t.boolean  "flagged"
    t.string   "scrape_type"
  end

  create_table "trends", :force => true do |t|
    t.string   "term"
    t.datetime "created_at"
    t.datetime "ended_at"
    t.integer  "tweet_count"
    t.integer  "scrape_id"
  end

  create_table "tweets", :force => true do |t|
    t.integer  "twitter_id"
    t.datetime "published"
    t.string   "content"
    t.string   "source"
    t.string   "language"
    t.integer  "user_id"
    t.integer  "scrape_id"
    t.string   "screen_name"
    t.string   "location"
    t.string   "link"
    t.string   "in_reply_to_status_id"
    t.string   "in_reply_to_user_id"
    t.string   "favorited"
    t.string   "truncated"
    t.string   "in_reply_to_screen_name"
    t.integer  "to_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lat"
    t.string   "lon"
    t.integer  "metadata_id"
  end

  create_table "users", :force => true do |t|
    t.integer  "twitter_id"
    t.string   "name"
    t.string   "screen_name"
    t.string   "location"
    t.string   "description"
    t.string   "profile_image_url"
    t.string   "url"
    t.boolean  "protected"
    t.integer  "followers_count"
    t.string   "profile_background_color"
    t.string   "profile_text_color"
    t.string   "profile_link_color"
    t.string   "profile_sidebar_fill_color"
    t.string   "profile_sidebar_border_color"
    t.integer  "friends_count"
    t.datetime "created_at"
    t.integer  "favourites_count"
    t.integer  "utc_offset"
    t.string   "time_zone"
    t.string   "profile_background_image_url"
    t.boolean  "profile_background_tile"
    t.boolean  "notifications"
    t.boolean  "geo_enabled"
    t.boolean  "verified"
    t.boolean  "following"
    t.integer  "statuses_count"
    t.integer  "scrape_id"
    t.boolean  "contributors_enabled"
    t.string   "lang"
    t.integer  "metadata_id"
  end

end
