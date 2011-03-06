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

ActiveRecord::Schema.define(:version => 20110219214251) do

  create_table "analysis_metadatas", :force => true do |t|
    t.boolean "finished",      :default => false, :null => false
    t.string  "function"
    t.string  "instance_id"
    t.boolean "processing",    :default => false, :null => false
    t.integer "collection_id"
    t.boolean "rest",          :default => false, :null => false
    t.string  "save_path"
    t.integer "curation_id"
  end

  add_index "analysis_metadatas", ["function", "collection_id"], :name => "analysis_metadatas_function_collection_id", :unique => true

  create_table "analytical_instances", :force => true do |t|
    t.string   "instance_id",                                      :null => false
    t.string   "hostname",                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at",    :default => '2010-01-01 01:01:01', :null => false
    t.string   "instance_name",                                    :null => false
    t.integer  "pid",           :default => 0,                     :null => false
    t.boolean  "killed",        :default => false
    t.string   "slug"
  end

  create_table "analytical_offerings", :force => true do |t|
    t.string  "title",                               :null => false
    t.text    "description",                         :null => false
    t.string  "function",                            :null => false
    t.string  "source_code_link",                    :null => false
    t.string  "created_by",                          :null => false
    t.string  "created_by_link",                     :null => false
    t.boolean "rest",             :default => false, :null => false
    t.boolean "enabled",          :default => false, :null => false
    t.string  "save_path"
    t.string  "access_level"
  end

  create_table "auth_users", :force => true do |t|
    t.string  "user_name"
    t.string  "password"
    t.boolean "flagged",       :default => false, :null => false
    t.string  "instance_id"
    t.string  "hostname"
    t.string  "instance_name"
  end

  create_table "collections", :force => true do |t|
    t.integer  "researcher_id",      :default => 0,                     :null => false
    t.datetime "created_at",         :default => '2010-01-01 01:01:01', :null => false
    t.string   "name"
    t.datetime "updated_at",         :default => '2010-01-01 01:01:01', :null => false
    t.integer  "scrape_id",          :default => 0,                     :null => false
    t.boolean  "finished",           :default => false,                 :null => false
    t.boolean  "analyzed",           :default => false,                 :null => false
    t.boolean  "notified",           :default => false,                 :null => false
    t.string   "folder_name"
    t.string   "instance_id"
    t.boolean  "flagged",            :default => false,                 :null => false
    t.boolean  "single_dataset",     :default => false,                 :null => false
    t.boolean  "scraped_collection", :default => false,                 :null => false
    t.integer  "tweets_count",       :default => 0,                     :null => false
    t.integer  "users_count",        :default => 0,                     :null => false
    t.string   "scrape_method"
    t.boolean  "mothballed",         :default => false,                 :null => false
    t.boolean  "private_data",       :default => false,                 :null => false
  end

  add_index "collections", ["researcher_id", "scrape_id", "folder_name"], :name => "unique_collection"

  create_table "collections_rest_metadatas", :id => false, :force => true do |t|
    t.integer "collection_id",    :null => false
    t.integer "rest_metadata_id", :null => false
  end

  add_index "collections_rest_metadatas", ["collection_id", "rest_metadata_id"], :name => "collection_rest_metadata_id", :unique => true

  create_table "collections_stream_metadatas", :id => false, :force => true do |t|
    t.integer "collection_id",      :null => false
    t.integer "stream_metadata_id", :null => false
  end

  add_index "collections_stream_metadatas", ["collection_id", "stream_metadata_id"], :name => "collection_stream_metadata_id", :unique => true

  create_table "comments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "researcher_id"
    t.integer  "post_id"
    t.text     "comment"
    t.string   "title",         :null => false
  end

  create_table "curation_datasets", :id => false, :force => true do |t|
    t.integer "curation_id"
    t.integer "dataset_id"
  end

  create_table "curations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "researcher_id"
    t.boolean  "single_dataset", :default => false
    t.boolean  "analyzed",       :default => false
  end

  create_table "datasets", :force => true do |t|
    t.string   "term"
    t.string   "scrape_type"
    t.datetime "start_time"
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "scrape_finished",               :default => false
    t.string   "instance_id",     :limit => 40
    t.boolean  "analyzed",                      :default => false
    t.integer  "tweets_count"
    t.integer  "users_count"
    t.string   "params"
  end

  create_table "edges", :force => true do |t|
    t.integer  "graph_id",                   :default => 0,     :null => false
    t.string   "start_node",                                    :null => false
    t.string   "end_node",                                      :null => false
    t.integer  "edge_id",       :limit => 8, :default => 0,     :null => false
    t.datetime "time"
    t.integer  "collection_id",              :default => 0,     :null => false
    t.boolean  "flagged",                    :default => false, :null => false
    t.string   "lock"
    t.string   "style",                                         :null => false
  end

  add_index "edges", ["collection_id"], :name => "edge_collection_id"
  add_index "edges", ["end_node"], :name => "end_node"
  add_index "edges", ["graph_id", "collection_id"], :name => "edge_graph_id_collection_id"
  add_index "edges", ["graph_id"], :name => "edge_graph_id"
  add_index "edges", ["start_node", "end_node", "edge_id", "style", "graph_id"], :name => "unique_edge", :unique => true
  add_index "edges", ["start_node"], :name => "start_node"
  add_index "edges", ["time"], :name => "edges_time"

  create_table "failures", :force => true do |t|
    t.string   "message",     :null => false
    t.text     "trace",       :null => false
    t.datetime "created_at"
    t.string   "instance_id", :null => false
  end

  create_table "graph_points", :force => true do |t|
    t.string  "label",                        :null => false
    t.integer "value",         :default => 0, :null => false
    t.integer "graph_id",      :default => 0, :null => false
    t.integer "collection_id", :default => 0, :null => false
  end

  add_index "graph_points", ["collection_id"], :name => "graph_point_collection_id"
  add_index "graph_points", ["graph_id", "collection_id"], :name => "graph_point_collection_id_graph_id"
  add_index "graph_points", ["graph_id"], :name => "graph_point_graph_id"
  add_index "graph_points", ["label", "graph_id", "collection_id"], :name => "label_graph_collection", :unique => true

  create_table "graphs", :force => true do |t|
    t.string   "title",                            :null => false
    t.string   "style",                            :null => false
    t.integer  "collection_id", :default => 0,     :null => false
    t.integer  "month"
    t.integer  "year"
    t.boolean  "written",       :default => false, :null => false
    t.string   "lock"
    t.boolean  "flagged",       :default => false, :null => false
    t.datetime "time_slice"
    t.integer  "hour"
    t.integer  "date"
    t.integer  "curation_id"
  end

  add_index "graphs", ["hour"], :name => "hour"
  add_index "graphs", ["month", "year", "hour"], :name => "day_2"
  add_index "graphs", ["month", "year"], :name => "month_3"
  add_index "graphs", ["month"], :name => "month"
  add_index "graphs", ["title", "style", "collection_id", "time_slice", "year", "month", "date", "hour"], :name => "unique_graph", :unique => true
  add_index "graphs", ["year"], :name => "year"

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

  create_table "instances", :force => true do |t|
    t.string   "instance_id",   :limit => 40
    t.string   "hostname"
    t.string   "instance_name"
    t.integer  "pid"
    t.boolean  "killed",                      :default => false
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "instance_type"
  end

  create_table "locks", :force => true do |t|
    t.string   "classname"
    t.integer  "with_id"
    t.string   "instance_id", :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locks", ["classname", "with_id"], :name => "classname_with_id", :unique => true

  create_table "news", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "researcher_id"
    t.string   "headline"
    t.text     "post"
    t.boolean  "page_item",     :null => false
    t.string   "slug",          :null => false
    t.boolean  "raw_html",      :null => false
  end

  create_table "pending_emails", :force => true do |t|
    t.boolean "sent",            :default => false
    t.text    "message_content",                    :null => false
    t.string  "recipient",                          :null => false
    t.string  "subject",                            :null => false
  end

  add_index "pending_emails", ["recipient", "subject"], :name => "unique_email", :unique => true

  create_table "researchers", :force => true do |t|
    t.string   "user_name",                 :limit => 20,                                    :null => false
    t.string   "email",                                                                      :null => false
    t.string   "reset_code"
    t.string   "role",                                    :default => "User",                :null => false
    t.datetime "join_date",                               :default => '2010-01-01 01:01:01', :null => false
    t.datetime "last_login",                              :default => '2010-01-01 01:01:01', :null => false
    t.datetime "last_access",                             :default => '2010-01-01 01:01:01', :null => false
    t.text     "info"
    t.string   "website_url"
    t.string   "location",                                :default => "United States",       :null => false
    t.string   "salt"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at",               :default => '2010-01-01 01:01:01', :null => false
    t.string   "crypted_password"
    t.boolean  "share_email",                             :default => false,                 :null => false
    t.boolean  "private_data",                            :default => false,                 :null => false
    t.boolean  "hidden_account",                          :default => false,                 :null => false
  end

  create_table "rest_instances", :force => true do |t|
    t.string   "instance_id",                                      :null => false
    t.string   "hostname",                                         :null => false
    t.datetime "created_at",    :default => '2010-01-01 01:01:01', :null => false
    t.datetime "updated_at",    :default => '2010-01-01 01:01:01', :null => false
    t.string   "instance_name",                                    :null => false
    t.integer  "pid",                                              :null => false
    t.boolean  "killed",        :default => false
    t.string   "slug"
  end

  create_table "rest_metadatas", :force => true do |t|
    t.integer  "scrape_id",     :default => 0,                     :null => false
    t.boolean  "finished",      :default => false,                 :null => false
    t.boolean  "flagged",       :default => false,                 :null => false
    t.string   "instance_id"
    t.datetime "created_at",    :default => '2010-01-01 01:01:01', :null => false
    t.datetime "updated_at",    :default => '2010-01-01 01:01:01', :null => false
    t.integer  "researcher_id", :default => 0,                     :null => false
    t.integer  "collection_id", :default => 0,                     :null => false
    t.integer  "tweets_count",  :default => 0,                     :null => false
    t.integer  "users_count",   :default => 0,                     :null => false
    t.text     "source_data"
  end

  create_table "scrapes", :force => true do |t|
    t.integer  "researcher_id"
    t.string   "name",                  :default => "A Default Scrape Name"
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
    t.datetime "last_branch_check"
    t.string   "humanized_length",      :default => "0"
    t.datetime "run_ends",              :default => '2010-01-01 00:00:00',   :null => false
    t.integer  "primary_collection_id", :default => 0,                       :null => false
    t.string   "ref_data"
  end

  add_index "scrapes", ["finished"], :name => "finished"
  add_index "scrapes", ["scrape_finished"], :name => "scrape_finished"

  create_table "stream_instances", :force => true do |t|
    t.string   "instance_id",                                                   :null => false
    t.string   "hostname",                                                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at",                 :default => '2010-01-01 01:01:01', :null => false
    t.string   "instance_name",                                                 :null => false
    t.integer  "pid",           :limit => 1,                                    :null => false
    t.boolean  "killed",                     :default => false
    t.string   "slug"
  end

  create_table "stream_metadatas", :force => true do |t|
    t.integer  "scrape_id",      :default => 0,                     :null => false
    t.boolean  "finished",       :default => false
    t.string   "term",                                              :null => false
    t.string   "sanitized_term",                                    :null => false
    t.boolean  "branching",      :default => false,                 :null => false
    t.boolean  "flagged",        :default => false,                 :null => false
    t.string   "instance_id"
    t.datetime "created_at",     :default => '2010-01-01 01:01:01', :null => false
    t.datetime "updated_at",     :default => '2010-01-01 01:01:01', :null => false
    t.integer  "researcher_id",                                     :null => false
    t.integer  "collection_id"
    t.integer  "tweets_count",   :default => 0,                     :null => false
    t.integer  "users_count",    :default => 0,                     :null => false
  end

  add_index "stream_metadatas", ["flagged"], :name => "flagged"
  add_index "stream_metadatas", ["instance_id"], :name => "instance_id"
  add_index "stream_metadatas", ["scrape_id"], :name => "scrape_id"
  add_index "stream_metadatas", ["term", "collection_id", "scrape_id", "researcher_id"], :name => "unique_scrape", :unique => true

  create_table "tweets", :force => true do |t|
    t.integer  "twitter_id",              :limit => 8, :default => 0
    t.text     "text"
    t.text     "source"
    t.string   "language"
    t.integer  "user_id",                 :limit => 8, :default => 0
    t.string   "screen_name"
    t.string   "location"
    t.integer  "in_reply_to_status_id",   :limit => 8, :default => 0
    t.integer  "in_reply_to_user_id",     :limit => 8, :default => 0
    t.string   "truncated"
    t.string   "in_reply_to_screen_name"
    t.datetime "created_at"
    t.string   "lat"
    t.string   "lon"
    t.boolean  "flagged",                              :default => false
    t.integer  "dataset_id"
    t.integer  "retweet_count"
  end

  add_index "tweets", ["screen_name"], :name => "screen_name"
  add_index "tweets", ["twitter_id", "dataset_id"], :name => "index_tweets_on_twitter_id_and_dataset_id", :unique => true

  create_table "users", :force => true do |t|
    t.integer  "twitter_id",                   :default => 0
    t.string   "name"
    t.string   "screen_name"
    t.string   "location"
    t.string   "description"
    t.string   "profile_image_url"
    t.string   "url"
    t.boolean  "protected",                    :default => false
    t.integer  "followers_count",              :default => 0
    t.string   "profile_background_color"
    t.string   "profile_text_color"
    t.string   "profile_link_color"
    t.string   "profile_sidebar_fill_color"
    t.string   "profile_sidebar_border_color"
    t.integer  "friends_count",                :default => 0
    t.datetime "created_at"
    t.integer  "favourites_count",             :default => 0
    t.integer  "utc_offset",                   :default => 0
    t.string   "time_zone"
    t.string   "profile_background_image_url"
    t.boolean  "profile_background_tile",      :default => false
    t.boolean  "notifications",                :default => false
    t.boolean  "geo_enabled",                  :default => false
    t.boolean  "verified",                     :default => false
    t.boolean  "following",                    :default => false
    t.integer  "statuses_count",               :default => 0
    t.boolean  "contributors_enabled",         :default => false
    t.string   "lang"
    t.boolean  "flagged",                      :default => false
    t.integer  "listed_count"
    t.integer  "dataset_id"
  end

  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id", :unique => true

  create_table "whitelistings", :primary_key => "hostname", :force => true do |t|
    t.string  "ip",          :null => false
    t.boolean "whitelisted", :null => false
  end

end
