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

ActiveRecord::Schema.define(:version => 20100815181606) do

  create_table "analysis_metadatas", :force => true do |t|
    t.boolean "finished",      :default => false
    t.string  "function"
    t.string  "instance_id"
    t.boolean "processing",    :default => false
    t.integer "collection_id"
    t.boolean "rest",          :default => false
    t.string  "save_path"
  end

  add_index "analysis_metadatas", ["function", "collection_id"], :name => "analysis_metadatas_function_collection_id", :unique => true

  create_table "analytical_instances", :force => true do |t|
    t.string   "instance_id"
    t.string   "hostname"
    t.datetime "created_at",    :default => '2010-01-01 01:01:01'
    t.datetime "updated_at",    :default => '2010-01-01 01:01:01'
    t.string   "instance_name"
    t.integer  "pid"
    t.boolean  "killed",        :default => false
    t.string   "slug"
  end

  create_table "analytical_offerings", :force => true do |t|
    t.string  "title"
    t.text    "description"
    t.string  "function"
    t.string  "source_code_link"
    t.string  "created_by"
    t.string  "created_by_link"
    t.boolean "rest",             :default => false
    t.boolean "enabled",          :default => false
    t.string  "save_path"
    t.string  "access_level"
  end

  create_table "auth_users", :force => true do |t|
    t.string  "user_name"
    t.string  "password"
    t.boolean "flagged",       :default => false
    t.string  "instance_id"
    t.string  "hostname"
    t.string  "instance_name"
  end

  create_table "collections", :force => true do |t|
    t.integer  "researcher_id"
    t.datetime "created_at",         :default => '2010-01-01 01:01:01'
    t.string   "name"
    t.datetime "updated_at",         :default => '2010-01-01 01:01:01'
    t.integer  "scrape_id"
    t.boolean  "finished",           :default => false
    t.boolean  "analyzed",           :default => false
    t.boolean  "notified",           :default => false
    t.string   "folder_name"
    t.string   "instance_id"
    t.boolean  "flagged",            :default => false
    t.boolean  "single_dataset",     :default => false
    t.boolean  "scraped_collection", :default => false
    t.integer  "tweets_count"
    t.integer  "users_count"
    t.string   "scrape_method"
    t.boolean  "mothballed",         :default => false
    t.boolean  "private_data"
  end

  add_index "collections", ["researcher_id", "scrape_id", "folder_name"], :name => "unique_collection", :unique => true

  create_table "collections_rest_metadatas", :id => false, :force => true do |t|
    t.integer "collection_id"
    t.integer "rest_metadata_id"
  end

  add_index "collections_rest_metadatas", ["collection_id", "rest_metadata_id"], :name => "collection_rest_metadata_id", :unique => true

  create_table "collections_stream_metadatas", :id => false, :force => true do |t|
    t.integer "collection_id"
    t.integer "stream_metadata_id"
  end

  add_index "collections_stream_metadatas", ["collection_id", "stream_metadata_id"], :name => "collection_stream_metadata_id", :unique => true

  create_table "comments", :force => true do |t|
    t.datetime "created_at",    :default => '2010-01-01 01:01:01'
    t.datetime "updated_at",    :default => '2010-01-01 01:01:01'
    t.integer  "researcher_id"
    t.integer  "post_id"
    t.text     "comment"
    t.string   "title"
  end

  create_table "edges", :force => true do |t|
    t.integer  "graph_id"
    t.string   "start_node"
    t.string   "end_node"
    t.integer  "edge_id",       :limit => 8
    t.datetime "time",                       :default => '2010-01-01 01:01:01'
    t.integer  "collection_id"
    t.boolean  "flagged",                    :default => false
    t.string   "lock"
    t.string   "style"
  end

  add_index "edges", ["collection_id"], :name => "index_edges_on_collection_id"
  add_index "edges", ["end_node"], :name => "index_edges_on_end_node"
  add_index "edges", ["graph_id", "collection_id"], :name => "index_edges_on_graph_id_and_collection_id"
  add_index "edges", ["graph_id"], :name => "index_edges_on_graph_id"
  add_index "edges", ["start_node", "end_node", "edge_id", "style"], :name => "unique_edge", :unique => true
  add_index "edges", ["start_node"], :name => "index_edges_on_start_node"

  create_table "failures", :force => true do |t|
    t.string   "message"
    t.text     "trace"
    t.datetime "created_at",  :default => '2010-01-01 01:01:01'
    t.string   "instance_id"
  end

  create_table "graph_points", :force => true do |t|
    t.string  "label"
    t.integer "value"
    t.integer "graph_id"
    t.integer "collection_id"
  end

  add_index "graph_points", ["collection_id"], :name => "index_graph_points_on_collection_id"
  add_index "graph_points", ["graph_id", "collection_id"], :name => "index_graph_points_on_graph_id_and_collection_id"
  add_index "graph_points", ["graph_id"], :name => "index_graph_points_on_graph_id"
  add_index "graph_points", ["label", "graph_id", "collection_id"], :name => "label_graph_collection", :unique => true

  create_table "graphs", :force => true do |t|
    t.string   "title"
    t.string   "style"
    t.integer  "collection_id"
    t.string   "hour"
    t.string   "minute"
    t.integer  "date"
    t.boolean  "written",       :default => false
    t.string   "lock"
    t.boolean  "flagged",       :default => false
    t.datetime "time_slice",    :default => '2010-01-01 01:01:01'
  end

  add_index "graphs", ["title", "style", "collection_id"], :name => "title_style_collection", :unique => true

  create_table "images", :force => true do |t|
    t.string  "parent_id"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.string  "headline"
    t.string  "researcher_id"
  end

  create_table "news", :force => true do |t|
    t.datetime "created_at",    :default => '2010-01-01 01:01:01'
    t.datetime "updated_at",    :default => '2010-01-01 01:01:01'
    t.integer  "researcher_id"
    t.string   "headline"
    t.text     "post"
    t.boolean  "page_item",     :default => false
    t.string   "slug"
    t.boolean  "raw_html",      :default => false
  end

  create_table "pending_emails", :force => true do |t|
    t.boolean "sent",            :default => false
    t.text    "message_content"
    t.string  "recipient"
    t.string  "subject"
  end

  add_index "pending_emails", ["recipient", "subject"], :name => "unique_email", :unique => true

  create_table "researchers", :force => true do |t|
    t.string   "user_name"
    t.string   "email"
    t.string   "reset_code"
    t.string   "role",                      :default => "User"
    t.datetime "join_date",                 :default => '2010-01-01 01:01:01'
    t.datetime "last_login",                :default => '2010-01-01 01:01:01'
    t.datetime "last_access",               :default => '2010-01-01 01:01:01'
    t.text     "info"
    t.string   "website_url"
    t.string   "location",                  :default => "United States"
    t.string   "salt"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at", :default => '2010-01-01 01:01:01'
    t.string   "crypted_password"
    t.boolean  "share_email",               :default => false
    t.boolean  "private_data"
    t.boolean  "hidden_account"
  end

  add_index "researchers", ["user_name"], :name => "index_researchers_on_user_name", :unique => true

  create_table "rest_instances", :force => true do |t|
    t.string   "instance_id"
    t.string   "hostname"
    t.datetime "created_at",    :default => '2010-01-01 01:01:01'
    t.datetime "updated_at",    :default => '2010-01-01 01:01:01'
    t.string   "instance_name"
    t.integer  "pid"
    t.boolean  "killed",        :default => false
    t.string   "slug"
  end

  create_table "rest_metadatas", :force => true do |t|
    t.integer  "scrape_id"
    t.boolean  "finished",      :default => false
    t.boolean  "flagged",       :default => false
    t.string   "instance_id",   :default => ""
    t.datetime "created_at",    :default => '2010-01-01 01:01:01'
    t.datetime "updated_at",    :default => '2010-01-01 01:01:01'
    t.integer  "researcher_id"
    t.integer  "collection_id"
    t.integer  "tweets_count"
    t.integer  "users_count"
    t.text     "source_data"
  end

  create_table "scrapes", :force => true do |t|
    t.integer  "researcher_id"
    t.string   "name",                  :default => "A default Scrape Name"
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "finished",              :default => false
    t.boolean  "scrape_finished",       :default => false
    t.string   "folder_name"
    t.string   "instance_id"
    t.boolean  "flagged",               :default => false
    t.string   "scrape_type"
    t.boolean  "branching",             :default => false
    t.datetime "last_branch_check",     :default => '2010-01-01 01:01:01'
    t.string   "humanized_length"
    t.datetime "run_ends",              :default => '2010-01-01 01:01:01'
    t.integer  "primary_collection_id"
    t.string   "ref_data"
  end

  add_index "scrapes", ["finished"], :name => "index_scrapes_on_finished"
  add_index "scrapes", ["scrape_finished"], :name => "index_scrapes_on_scrape_finished"

  create_table "stream_instances", :force => true do |t|
    t.string   "instance_id"
    t.string   "hostname"
    t.datetime "created_at",    :default => '2010-01-01 01:01:01'
    t.datetime "updated_at",    :default => '2010-01-01 01:01:01'
    t.string   "instance_name"
    t.integer  "pid"
    t.boolean  "killed",        :default => false
    t.string   "slug"
  end

  create_table "stream_metadatas", :force => true do |t|
    t.integer  "scrape_id"
    t.boolean  "finished",       :default => false
    t.string   "term"
    t.string   "sanitized_term"
    t.boolean  "branching",      :default => false
    t.boolean  "flagged",        :default => false
    t.string   "instance_id",    :default => ""
    t.datetime "created_at",     :default => '2010-01-01 01:01:01'
    t.datetime "updated_at",     :default => '2010-01-01 01:01:01'
    t.integer  "researcher_id"
    t.integer  "collection_id"
    t.integer  "tweets_count"
    t.integer  "users_count"
  end

  add_index "stream_metadatas", ["flagged"], :name => "index_stream_metadatas_on_flagged"
  add_index "stream_metadatas", ["instance_id"], :name => "index_stream_metadatas_on_instance_id"
  add_index "stream_metadatas", ["scrape_id"], :name => "index_stream_metadatas_on_scrape_id"
  add_index "stream_metadatas", ["term", "collection_id", "scrape_id", "researcher_id"], :name => "unique_scrape", :unique => true

  create_table "tweets", :force => true do |t|
    t.integer  "twitter_id",              :limit => 8, :default => 0
    t.text     "text"
    t.text     "source"
    t.string   "language"
    t.integer  "user_id",                 :limit => 8, :default => 0
    t.integer  "scrape_id"
    t.string   "screen_name"
    t.string   "location"
    t.integer  "in_reply_to_status_id",   :limit => 8, :default => 0
    t.integer  "in_reply_to_user_id",     :limit => 8, :default => 0
    t.string   "favorited"
    t.string   "truncated"
    t.string   "in_reply_to_screen_name"
    t.datetime "created_at",                           :default => '2010-01-01 01:01:01'
    t.string   "lat"
    t.string   "lon"
    t.integer  "metadata_id"
    t.string   "metadata_type",                        :default => "stream_metadata"
    t.string   "instance_id",                          :default => ""
    t.boolean  "flagged",                              :default => false
  end

  add_index "tweets", ["created_at"], :name => "index_tweets_on_created_at"
  add_index "tweets", ["metadata_id", "metadata_type"], :name => "index_tweets_on_metadata_id_and_metadata_type"
  add_index "tweets", ["metadata_id", "scrape_id"], :name => "index_tweets_on_metadata_id_and_scrape_id"
  add_index "tweets", ["metadata_id"], :name => "index_tweets_on_metadata_id"
  add_index "tweets", ["metadata_type", "scrape_id", "metadata_id", "screen_name"], :name => "tweets_twitter_id_scrape_id_metadata_id", :unique => true
  add_index "tweets", ["scrape_id"], :name => "index_tweets_on_scrape_id"
  add_index "tweets", ["screen_name"], :name => "index_tweets_on_screen_name"

  create_table "users", :force => true do |t|
    t.integer  "twitter_id"
    t.string   "name"
    t.string   "screen_name"
    t.string   "location"
    t.string   "description"
    t.string   "profile_image_url"
    t.string   "url"
    t.boolean  "protected",                    :default => false
    t.integer  "followers_count"
    t.string   "profile_background_color"
    t.string   "profile_text_color"
    t.string   "profile_link_color"
    t.string   "profile_sidebar_fill_color"
    t.string   "profile_sidebar_border_color"
    t.integer  "friends_count"
    t.datetime "created_at",                   :default => '2010-01-01 01:01:01'
    t.integer  "favourites_count"
    t.integer  "utc_offset"
    t.string   "time_zone"
    t.string   "profile_background_image_url"
    t.boolean  "profile_background_tile",      :default => false
    t.boolean  "notifications",                :default => false
    t.boolean  "geo_enabled",                  :default => false
    t.boolean  "verified",                     :default => false
    t.boolean  "following",                    :default => false
    t.integer  "statuses_count"
    t.integer  "scrape_id"
    t.boolean  "contributors_enabled",         :default => false
    t.string   "lang"
    t.integer  "metadata_id"
    t.string   "metadata_type",                :default => "stream_metadata"
    t.string   "instance_id"
    t.boolean  "flagged",                      :default => false
    t.integer  "listed_count"
  end

  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["metadata_id", "metadata_type"], :name => "index_users_on_metadata_id_and_metadata_type"
  add_index "users", ["metadata_id", "scrape_id"], :name => "index_users_on_metadata_id_and_scrape_id"
  add_index "users", ["metadata_id"], :name => "index_users_on_metadata_id"
  add_index "users", ["metadata_type", "scrape_id", "metadata_id", "screen_name"], :name => "users_screen_name_scrape_id_metadata_id", :unique => true
  add_index "users", ["scrape_id"], :name => "index_users_on_scrape_id"

  create_table "whitelistings", :force => true do |t|
    t.string  "hostname"
    t.string  "ip"
    t.boolean "whitelisted", :default => false
  end

  add_index "whitelistings", ["hostname"], :name => "index_whitelistings_on_hostname", :unique => true

end
