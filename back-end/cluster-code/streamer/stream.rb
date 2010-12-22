class Stream
  
  require "#{ROOT_FOLDER}cluster-code/streamer/stream_flow"
  require "#{ROOT_FOLDER}cluster-code/streamer/scraper/tweet_helper"
  require "#{ROOT_FOLDER}cluster-code/streamer/scraper/user_helper"
  require "#{ROOT_FOLDER}cluster-code/streamer/scraper/general_helpers"
  require "#{ROOT_FOLDER}cluster-code/streamer/scraper/environmental"
  
  attr_accessor :username, :password, :length, :geo_only, :counter, :length, :end_data, :type, :params, :metadatas, :previous_data_count, :current_data_count
  
  def initialize(username, password)
    @username, @password = username, password
    @end_data = {}
    @metadatas = StreamMetadata.find_all({:flagged => true, :instance_id => $w.instance_id})
  end
  
###MANAGEMENT UTILITIES###

  def update_mix(metadatas)
    si = StreamInstance.find({:instance_id => $w.instance_id})
    si.updated_at = Time.ntp
    si.save
    @metadatas += metadatas
    @metadatas = @metadatas.uniq
    if @metadatas.length > MAX_TRACK_IDS
      denied_metadatas = []
      @metadatas -= denied_metadatas = @metadatas[MAX_TRACK_IDS-1..metadatas.length]
      Database.update_attributes(:stream_metadatas, denied_metadatas, {"flagged" => false, "instance_id" => "", "created_at" => Time.ntp, "updated_at" => Time.ntp})
    end
    finished_metadatas = StreamMetadata.find_all({:finished => true, :flagged => true, :instance_id => $w.instance_id})
    Database.update_attributes(:stream_metadatas, finished_metadatas, {"flagged" => false, "instance_id" => "", "created_at" => Time.ntp, "updated_at" => Time.ntp}) if finished_metadatas.length > 0
    @metadatas = StreamMetadata.find_all({:finished => false, :flagged => true, :instance_id => $w.instance_id})
  end
  
  def stream_data
    track_terms = @metadatas.collect{|metadata| metadata.sanitized_term}.compact.uniq
    actual_terms = @metadatas.collect{|metadata| metadata.term}.compact.uniq
    @length, @counter = determine_timer_values
    track(track_terms, actual_terms)
    si = StreamInstance.find({:instance_id => $w.instance_id})
    si.updated_at = Time.ntp
    si.save
  end
###REQUEST TYPES###

  def track(track_terms, actual_terms)
    #Pull is just search data, and should look like ["lol", "haha"] etc or ["lol"] for only one term
    #http://#{HOSTNAME}/1/statuses/filter.json?track="lol"
    @type = "track"
    @params = actual_terms
    base_url = "/1/statuses/filter.json?#{@type}="
    parameterized_call(base_url, track_terms, actual_terms)
  end
  
  def sample
    #Sample is a smattering of all tweets
    @type = "sample"
    @params = nil
    @timer = Time.ntp.to_i+@length
    @end_data["sample"] = []
    base_url = "/1/statuses/sample.json"
    StreamFlow.get_hashes(base_url)
    g = ""
    store_to_db
    clean_up_metadatas
  end
  
###FLOW TYPES###
  
  def parameterized_call(base_url, track_terms, actual_terms)
    track_terms.collect!{ |param| param = param.class == Array ? param.join(",") : param }
    actual_terms.each do |param|
      @end_data[param] = []
    end
    StreamFlow.get_hashes(base_url+track_terms.join(",")) if track_terms.length > 0
    store_to_db
    clean_up_metadatas
  end
  
###UTILITY METHODS###
  
  def determine_timer_values
    scrapes_involved = @metadatas.collect{|metadata| metadata.scrape_id}.uniq.collect{|id| Scrape.find({:id => id})}.compact
    times = {}
    scrapes_involved.collect{|scrape| times[scrape.created_at.to_i+scrape.length - Time.ntp.to_i] = [scrape.created_at.to_i, scrape.length]}.sort.first
    return times.sort.first.last.first, times.sort.first.last.last
  end

  def clean_up_metadatas
    @end_data = {}
    scrapes = @metadatas.collect{|metadata| metadata.scrape_id}.uniq.collect{|scrape_id| Scrape.find({:id => scrape_id})}
    Database.update_attributes(:scrapes, scrapes, {"updated_at" => Time.ntp})
    finished_scrapes = scrapes.reject{|scrape| !U.times_up(scrape.created_at.to_i, scrape.length)}
    Database.update_attributes(:scrapes, finished_scrapes, {"scrape_finished" => true, "flagged" => false, "instance_id" => ""})
    finished_metadatas = []
    finished_scrapes.each do |scrape|
      @metadatas.each do |metadata|
        if scrape.id == metadata.scrape_id
          finished_metadatas << metadata
          @metadatas = @metadatas-[metadata]
        end
      end
    end
    Database.update_attributes(:stream_metadatas, finished_metadatas, {"finished" => true, "flagged" => false, "instance_id" => ""})
  end

###DB PREP METHODS### 

  def store_to_db
    @metadatas.each do |metadata|
      @end_data.each_pair do |term, tweets|
        if metadata.term == term
          db_save(metadata, tweets)
        end
      end
    end
  end
  
  def db_save(metadata, tweets)
    # This line was changed because flatify was moved to internal tweet parsing - Devin, May 19, 2010 @ 8:56pm
    # raw_tweets = tweets.collect{|t| t.flatify}    
    raw_tweets = tweets.collect{|t| t.flatify}
    raw_users = tweets.collect {|u| u["user"]}
    hashed_tweet_data = TweetHelper.hash_tweets(raw_tweets)
    hashed_user_data = UserHelper.hash_users(raw_users) 
    Environment.set_db(Environment.db)
    U.append_and_save(hashed_tweet_data.merge(hashed_user_data), metadata)
  end
end