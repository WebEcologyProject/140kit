module RestFlow
  
  attr_accessor :rest
  
  def self.rest
    if Scheduler.rest("User Source Scrape")
      RestFlow.determine_rest_work
    else
      puts "No Scrapes found to work on at this time."
    end 
  end
  
  def self.determine_rest_work
    metadata = $w.rest_instance.metadata
    case metadata.scrape.scrape_type.downcase
    when "user source scrape"
      RestFlow.claim_new_users
      RestFlow.unlock_metadata
      $w.rest_instance.collect_rest_data
      RestFlow.check_finished
    end
  end
  
  def self.claim_new_users
    metadata = $w.rest_instance.metadata
    if User.count({:metadata_id => $w.rest_instance.metadata.id, :metadata_type => 'rest_metadata'}) == 0
      users, folder_address = RestFlow.create_temp_file
      users_uploaded = 0
      user_groups = []
      while users_uploaded < users.length
        user_groups << users[users_uploaded..users_uploaded+MAX_ROW_COUNT_PER_BATCH]
        users_uploaded = users_uploaded+MAX_ROW_COUNT_PER_BATCH > users.length ? users.length : users_uploaded+MAX_ROW_COUNT_PER_BATCH
      end
      user_groups.collect{|ug| Database.save_all(:users => ug.collect{|user| {:screen_name => user, :metadata_id => metadata.id, :metadata_type => "rest_metadata", :scrape_id => metadata.scrape.id}})}
    end
    $w.rest_instance.users = [User.find({:metadata_id => metadata.id, :instance_id => $w.instance_id, :metadata_type => "rest_metadata", :twitter_id => 0, :limit => MAX_ROW_COUNT_PER_BATCH})].flatten
    if $w.rest_instance.users.first.nil?
      $w.rest_instance.users = [User.find({:metadata_id => metadata.id, :flagged => false, :metadata_type => "rest_metadata", :limit => MAX_ROW_COUNT_PER_BATCH})].flatten.compact
      Database.update_attributes(:users, $w.rest_instance.users, {"flagged" => true, "instance_id" => $w.instance_id})
    end
  end
  
  def self.create_temp_file
    `mkdir ../tmp_files/#{$w.instance_id}`
    source_data = `curl #{SITE_URL}/files/#{$w.rest_instance.metadata.source_data}`
    f = File.open("../tmp_files/#{$w.instance_id}/source_data.txt", "w")
    f.write(source_data)
    f.close
    f = File.open("../tmp_files/#{$w.instance_id}/source_data.txt", "r")
    data = f.read.split(",").collect{|d| d.strip}
    f.close
    return data, "../tmp_files/#{$w.instance_id}/source_data.txt"
  end
  
  def self.unlock_metadata
    metadata = $w.rest_instance.metadata
    metadata.flagged = false
    metadata.instance_id = ""
    metadata.save
  end
    
  def self.check_finished
    flagged = User.count({:metadata_id => $w.rest_instance.metadata.id, :metadata_type => 'rest_metadata', :flagged => true})
    total = User.count({:metadata_id => $w.rest_instance.metadata.id, :metadata_type => 'rest_metadata'})
    if flagged == total
      `rm -r ../tmp_files/#{$w.instance_id}`
      metadata_collection = $w.rest_instance.metadata.collection
      full_collection = Collection.find({:single_dataset => false, :scrape_id => $w.rest_instance.metadata.scrape.id})
      scrape_tweets_count = Tweet.count({:scrape_id => $w.rest_instance.metadata.scrape.id})
      scrape_users_count = User.count({:scrape_id => $w.rest_instance.metadata.scrape.id})
      metadata_tweets_count = Tweet.count({:metadata_id => $w.rest_instance.metadata.id, :metadata_type => 'rest_metadata'})
      metadata_users_count = User.count({:metadata_id => $w.rest_instance.metadata.id, :metadata_type => 'rest_metadata'})
      $w.rest_instance.metadata.finished = true
      $w.rest_instance.metadata.tweets_count = metadata_tweets_count
      $w.rest_instance.metadata.users_count = metadata_users_count
      $w.rest_instance.metadata.flagged = false
      $w.rest_instance.metadata.instance_id = ""
      $w.rest_instance.metadata.save
      metadata_collection.tweets_count = metadata_tweets_count
      metadata_collection.users_count = metadata_users_count
      metadata_collection.save
      $w.rest_instance.metadata.scrape.scrape_finished = true
      $w.rest_instance.metadata.save
      full_collection.tweets_count = scrape_tweets_count
      full_collection.users_count = scrape_users_count
      full_collection.save
    end
  end
end