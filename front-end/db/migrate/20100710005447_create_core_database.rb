class CreateCoreDatabase < ActiveRecord::Migration
    def self.up
      create_table :analysis_metadatas do |t|
        t.boolean :finished, :default => false
        t.string :function
        t.string :instance_id
        t.boolean :processing, :default => false
        t.integer :collection_id
        t.boolean :rest, :default => false
      end
      add_index(:analysis_metadatas, [:function, :collection_id], :unique => true, :name => "analysis_metadatas_function_collection_id")

      create_table :analytical_instances do |t|
        t.string :instance_id
        t.string :hostname
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.datetime :updated_at, :default => '2010-01-01 01:01:01'
        t.string :instance_name
        t.integer :pid
      end

      create_table :analytical_offerings do |t|
        t.string :title
        t.text :description
        t.string :function
        t.string :source_code_link
        t.string :created_by
        t.string :created_by_link
        t.boolean :rest, :default =>false
        t.boolean :enabled, :default =>false
      end

      create_table :auth_users do |t|
        t.string :user_name
        t.string :password
        t.boolean :flagged, :default =>false
        t.string :instance_id
        t.string :hostname
        t.string :instance_name
      end

      create_table :collections do |t|
        t.integer :id
        t.integer :researcher_id
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.string :name
        t.datetime :updated_at, :default => '2010-01-01 01:01:01'
        t.integer :scrape_id
        t.boolean :finished, :default =>false
        t.boolean :analyzed, :default =>false
        t.boolean :notified, :default =>false
        t.string :folder_name
        t.string :instance_id
        t.boolean :flagged, :default =>false
        t.boolean :single_dataset, :default =>false
        t.boolean :scraped_collection, :default =>false
        t.integer :tweets_count
        t.integer :users_count
        t.string :scrape_method
        t.boolean :mothballed, :default =>false
      end
      add_index(:collections, [:researcher_id, :scrape_id, :folder_name], :unique => true, :name => "unique_collection")

      create_table :collections_rest_metadatas do |t|
        t.integer :collection_id
        t.integer :rest_metadata_id
      end
      add_index(:collections_rest_metadatas, [:collection_id, :rest_metadata_id], :unique => true, :name => "collection_rest_metadata_id")

      create_table :collections_stream_metadatas do |t|
        t.integer :collection_id
        t.integer :stream_metadata_id
      end
      add_index(:collections_stream_metadatas, [:collection_id, :stream_metadata_id], :unique => true, :name => "collection_stream_metadata_id")

      create_table :comments do |t|
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.datetime :updated_at, :default => '2010-01-01 01:01:01'
        t.integer :researcher_id
        t.integer :post_id
        t.text :comment
        t.string :title
      end

      create_table :edges do |t|
        t.integer :graph_id
        t.string :start_node
        t.string :end_node
        t.integer :edge_id, :limit => 8
        t.datetime :time, :default => '2010-01-01 01:01:01'
        t.integer :collection_id
        t.boolean :flagged, :default =>false
        t.string :lock
        t.string :style
      end
      add_index(:edges, [:start_node, :end_node, :edge_id, :style], :unique => true, :length => {:start_node => 100, :end_node => 100, :edge_id => 20, :style => 100, :graph_id => 11}, :name => "unique_edge")
      add_index(:edges, :start_node)
      add_index(:edges, :end_node)
      add_index(:edges, :collection_id)
      add_index(:edges, :graph_id)
      add_index(:edges, [:graph_id, :collection_id])

      create_table :failures do |t|
        t.integer :id
        t.string :message
        t.text :trace
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.string :instance_id
      end

      create_table :graphs do |t|
        t.string :title
        t.string :style
        t.integer :collection_id
        t.string :hour
        t.string :minute
        t.string :date
        t.boolean :written, :default =>false
        t.string :lock
        t.boolean :flagged, :default =>false
        t.datetime :time_slice, :default => '2010-01-01 01:01:01'
      end
      add_index(:graphs, [:title, :style, :collection_id], :unique => true, :name => "title_style_collection")

      create_table :graph_points do |t|
        t.string :label
        t.integer :value
        t.integer :graph_id
        t.integer :collection_id
      end
      add_index(:graph_points, [:label, :graph_id, :collection_id], :unique => true, :name => "label_graph_collection")
      add_index(:graph_points, :collection_id)
      add_index(:graph_points, :graph_id)
      add_index(:graph_points, [:graph_id, :collection_id])

      create_table :images do |t|
        t.string :parent_id
        t.string :content_type
        t.string :filename
        t.string :thumbnail
        t.integer :size
        t.integer :width
        t.integer :height
        t.string :headline
        t.string :researcher_id
      end

      create_table :news do |t|
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.datetime :updated_at, :default => '2010-01-01 01:01:01'
        t.integer :researcher_id
        t.string :headline
        t.text :post
        t.boolean :page_item, :default =>false
        t.string :slug
        t.boolean :raw_html, :default =>false
      end

      create_table :pending_emails do |t|
        t.boolean :sent, :default =>false
        t.text :message_content
        t.string :recipient
        t.string :subject
      end
      add_index(:pending_emails, [:recipient, :subject], :length => {:recipient => 255, :subject => 255}, :unique => true, :name => "unique_email")

      create_table :researchers do |t|
        t.string :user_name
        t.string :email
        t.string :reset_code
        t.string :role, :default => "User"
        t.datetime :join_date, :default => '2010-01-01 01:01:01'
        t.datetime :last_login, :default => '2010-01-01 01:01:01'
        t.datetime :last_access, :default => '2010-01-01 01:01:01'
        t.text :info
        t.string :website_url
        t.string :location, :default => "United States"
        t.string :salt
        t.string :remember_token
        t.datetime :remember_token_expires_at, :default => '2010-01-01 01:01:01'
        t.string :crypted_password
        t.boolean :share_email, :default =>false
      end
      add_index(:researchers, :user_name, :unique => true)

      create_table :rest_instances do |t|
        t.string :instance_id
        t.string :hostname
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.datetime :updated_at, :default => '2010-01-01 01:01:01'
        t.string :instance_name
        t.integer :pid
      end

      create_table :rest_metadatas do |t|
        t.integer :scrape_id
        t.boolean :finished, :default =>false
        t.boolean :flagged, :default =>false
        t.string :instance_id, :default =>""
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.datetime :updated_at, :default => '2010-01-01 01:01:01'
        t.integer :researcher_id
        t.integer :collection_id
        t.integer :tweets_count
        t.integer :users_count
        t.text :source_data
      end

      create_table :scrapes do |t|
        t.integer :researcher_id
        t.string :name, :default => "A default Scrape Name"
        t.integer :length
        t.datetime :created_at
        t.datetime :updated_at
        t.boolean :finished, :default =>false
        t.boolean :scrape_finished, :default =>false
        t.string :folder_name
        t.string :instance_id
        t.boolean :flagged, :default =>false
        t.string :scrape_type
        t.boolean :branching, :default =>false
        t.datetime :last_branch_check, :default => '2010-01-01 01:01:01'
        t.string :humanized_length
        t.datetime :run_ends, :default => '2010-01-01 01:01:01'
        t.integer :primary_collection_id
        t.string :ref_data
      end
      add_index(:scrapes, :finished)
      add_index(:scrapes, :scrape_finished)

      create_table :stream_instances do |t|
        t.string :instance_id
        t.string :hostname
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.datetime :updated_at, :default => '2010-01-01 01:01:01'
        t.string :instance_name
        t.integer :pid
      end

      create_table :stream_metadatas do |t|
        t.integer :scrape_id
        t.boolean :finished, :default =>false
        t.string :term
        t.string :sanitized_term
        t.boolean :branching, :default =>false
        t.boolean :flagged, :default =>false
        t.string :instance_id, :default =>""
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.datetime :updated_at, :default => '2010-01-01 01:01:01'
        t.integer :researcher_id
        t.integer :collection_id
        t.integer :tweets_count
        t.integer :users_count
      end
      add_index(:stream_metadatas, [:term, :collection_id, :scrape_id, :researcher_id], :unique => true, :name => "unique_scrape")
      add_index(:stream_metadatas, :instance_id)
      add_index(:stream_metadatas, :flagged)
      add_index(:stream_metadatas, :scrape_id)

      create_table :tweets do |t|
        t.integer :twitter_id, :limit => 8, :default => 0
        t.text :text
        t.text :source
        t.string :language
        t.integer :user_id, :limit => 8, :default => 0
        t.integer :scrape_id
        t.string :screen_name
        t.string :location
        t.integer :in_reply_to_status_id, :limit => 8, :default => 0
        t.integer :in_reply_to_user_id, :limit => 8, :default => 0
        t.string :favorited
        t.string :truncated
        t.string :in_reply_to_screen_name
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.string :lat
        t.string :lon
        t.integer :metadata_id
        t.string :metadata_type, :default => 'stream_metadata'
        t.string :instance_id, :default =>""
        t.boolean :flagged, :default =>false
      end
      add_index(:tweets, [:metadata_type, :scrape_id, :metadata_id, :screen_name], :unique => true, :name => "tweets_twitter_id_scrape_id_metadata_id")
      add_index(:tweets, :scrape_id)
      add_index(:tweets, :screen_name)
      add_index(:tweets, :metadata_id)
      add_index(:tweets, [:metadata_id, :scrape_id])
      add_index(:tweets, [:metadata_id, :metadata_type])

      create_table :users do |t|
        t.integer :id
        t.integer :twitter_id
        t.string :name
        t.string :screen_name
        t.string :location
        t.string :description
        t.string :profile_image_url
        t.string :url
        t.boolean :protected, :default =>false
        t.integer :followers_count
        t.string :profile_background_color
        t.string :profile_text_color
        t.string :profile_link_color
        t.string :profile_sidebar_fill_color
        t.string :profile_sidebar_border_color
        t.integer :friends_count
        t.datetime :created_at, :default => '2010-01-01 01:01:01'
        t.integer :favourites_count
        t.integer :utc_offset
        t.string :time_zone
        t.string :profile_background_image_url
        t.boolean :profile_background_tile, :default =>false
        t.boolean :notifications, :default =>false
        t.boolean :geo_enabled, :default =>false
        t.boolean :verified, :default =>false
        t.boolean :following, :default =>false
        t.integer :statuses_count
        t.integer :scrape_id
        t.boolean :contributors_enabled, :default =>false
        t.string :lang
        t.integer :metadata_id
        t.string :metadata_type, :default => 'stream_metadata'
        t.string :instance_id
        t.boolean :flagged, :default =>false
      end
      add_index(:users, [:metadata_type, :scrape_id, :metadata_id, :screen_name], :unique => true, :name => "users_screen_name_scrape_id_metadata_id")
      add_index(:users, :scrape_id)
      add_index(:users, :metadata_id)
      add_index(:users, [:metadata_id, :scrape_id])
      add_index(:users, [:metadata_id, :metadata_type])

      create_table :whitelistings, :primary_key => false do |t|
        t.string :hostname
        t.string :ip
        t.boolean :whitelisted, :default => false
      end
      add_index(:whitelistings, :hostname, :unique => true)
    end

    def self.down
      drop_table :analysis_metadatas
      drop_table :analytical_instances
      drop_table :analytical_offerings
      drop_table :auth_users
      drop_table :collections
      drop_table :collections_rest_metadatas    
      drop_table :collections_stream_metadatas
      drop_table :comments
      drop_table :edges
      drop_table :failures
      drop_table :graphs
      drop_table :graph_points
      drop_table :images
      drop_table :news
      drop_table :pending_emails
      drop_table :researchers
      drop_table :rest_instances
      drop_table :rest_metadatas
      drop_table :scrapes
      drop_table :stream_instances
      drop_table :stream_metadatas
      drop_table :tweets
      drop_table :users
      drop_table :whitelistings
    end
  end
