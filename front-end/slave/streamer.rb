# require File.dirname(__FILE__)+'/../lib/active_record_extensions'
require File.dirname(__FILE__)+'/worker'
require File.dirname(__FILE__)+'/utils/user_helper'
require File.dirname(__FILE__)+'/utils/tweet_helper'
require File.dirname(__FILE__)+'/utils/u'

require 'eventmachine'
require 'em-http'
require 'json'

MAX_TRACK_IDS = 10000
MAX_ROW_COUNT_PER_BATCH = 1000
STREAM_API_ADDRESS = "http://stream.twitter.com"

class Streamer < Instance
  
  attr_accessor :user_account, :username, :password, :length, :geo_only, :counter, :length, :next_stop_time, :end_data, :type, :params, :metadatas, :previous_data_count, :current_data_count, :datasets, :stream
  
  def initialize
    super
    self.instance_type = "streamer"
    @end_data = {}
    @datasets = []#Dataset.find_all({:instance_id => $w.instance_id})
    at_exit { do_at_exit }
  end
  
  def do_at_exit
    unlock(@user_account)
    unlock_all(@datasets)
    self.destroy
  end
  
  def stream
    puts "Streaming..."
    check_in
    assign_user_account
    puts "Entering stream routine."
    loop do
      if !killed?
        stream_routine
      else
        puts "Just nappin'."
        sleep(SLEEP_CONSTANT)
      end
    end
  end
  
  def stream_routine
    add_datasets
    if !@datasets.empty?
      stream_data
    end
  end
  
  def assign_user_account
    puts "Assigning user account."
    message = true
    while @username.nil?
      user = AuthUser.unlocked(:first)
      if !user.nil? && lock(user)
        @user_account = user
        @username = user.user_name
        @password = user.password
        puts "Assigned #{@username}."
      else
        puts "No user accounts available." if message
        message = false
      end
      sleep(5)
    end
  end
  
  def add_datasets
   # datasets = Dataset.find_all({:scrape_finished => false, :scrape_type => ["Search", "Trend"]})
   datasets = Dataset.unlocked(:all, "scrape_finished = 0 AND scrape_type = 'Search'")
   return claim_new_datasets(datasets)
 end

 def claim_new_datasets(datasets) # for stream instances only right now
   # distribute datasets evenly
   return false if datasets.empty?
   num_instances = Instance.count(:conditions => {:instance_type => "streamer", :killed => false})
   datasets_per_instance = num_instances.zero? ? datasets.length : (datasets.length.to_f / num_instances.to_f).ceil
   datasets_to_claim = datasets[0..datasets_per_instance]
   if !datasets_to_claim.empty?
     claimed_datasets = lock_all(datasets_to_claim)
     if !claimed_datasets.empty?
       update_datasets(claimed_datasets)
       return true
     end
   end
   return false
 end
   
  def update_datasets(datasets)
    @datasets = @datasets|datasets
    if @datasets.length > MAX_TRACK_IDS
      denied_datasets = []
      @datasets -= (denied_datasets = @datasets[MAX_TRACK_IDS-1..datasets.length])
      unlock_all(denied_datasets)
      # Database.update_attributes(:datasets, denied_datasets, {"instance_id" => ""})
    end
    # @datasets = Dataset.find_all({:scrape_finished => false, :instance_id => $w.instance_id, :scrape_type => ["Search", "Trend"]})
  end
  
  def stream_data
    # new:
    track_terms = @datasets.collect {|d| d.term.sanitize_for_streaming }.compact.uniq # sanitize terms here???
    actual_terms = @datasets.collect {|d| d.term }.compact.uniq
    @start_time, @length = determine_timer_values
    # "counter" doesn't seem like a very appropriate name.
    # simpler solution for stop times:
    @next_stop_time = @start_time + @length
    puts "First dataset stops at #{@next_stop_time}."
    track(track_terms, actual_terms)
  end
  
###REQUEST TYPES###

  def track(track_terms, actual_terms)
    puts "Tracking #{track_terms.join(", ")}."
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
    @timer = Time.now.to_i+@length
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
    get_hashes(base_url+track_terms.join(",")) if track_terms.length > 0
    store_to_db
    clean_up_datasets
  end
  
###UTILITY METHODS###
  
  def determine_timer_values
    # returns the start time and length (both in seconds) of the scrape that ends the soonest
    # THIS SHOULD RETURN INSTEAD next_stop_time
    # IN TURN DEPRECATING @length AND @counter
    update_start_times
    refresh_datasets # this is absolutely necessary even while it's called in update_start_times above. huh!
    soonest_ending_dataset = @datasets.sort {|x,y| (x.start_time + x.length - DateTime.now.in_time_zone) <=> (y.start_time + y.length - DateTime.now.in_time_zone) }.first
    return soonest_ending_dataset.start_time.in_time_zone, soonest_ending_dataset.length
  end
  
  def update_start_times
    refresh_datasets
    datasets_to_be_started = @datasets.select {|d| d.start_time.nil? }
    Dataset.update_all({:start_time => DateTime.now.in_time_zone}, {:id => datasets_to_be_started.collect {|d| d.id}})
    refresh_datasets
  end
  
  def refresh_datasets
    @datasets = Dataset.all(:conditions => {:id => @datasets.collect {|d| d.id }})
  end
  
  def clean_up_datasets
    @end_data = {}
    scrape_finished_datasets = @datasets.select{|d| U.times_up?(d.start_time+d.length)}
    if !scrape_finished_datasets.empty?
      puts "Finished tracking #{scrape_finished_datasets.collect {|d| d.term }.join(", ")}"
      Dataset.update_all({:scrape_finished => true}, {:id => scrape_finished_datasets.collect {|d| d.id}})
      @datasets -= scrape_finished_datasets
    end
  end
  
###DB PREP METHODS### 

  def store_to_db
    @datasets.each do |dataset|
      @end_data.each_pair do |term, tweets|
        if dataset.term == term
          db_save(dataset, tweets)
        end
      end
    end
  end
  
  def db_save(dataset, tweets)
    # This line was changed because flatify was moved to internal tweet parsing - Devin, May 19, 2010 @ 8:56pm
    # The line commented is exactly the same as the following line - Ian, October 7, 2010 @ 9:01pm
    # raw_tweets = tweets.collect{|t| t.flatify}
    raw_tweets = tweets.collect{|t| t.flatify}
    raw_users = tweets.collect {|u| u["user"]}
    # hashed_tweet_data = TweetHelper.hash_tweets(raw_tweets)[:tweets]
    # hashed_user_data = UserHelper.hash_users(raw_users)[:users]
    # U.append_and_save(hashed_tweet_data.merge(hashed_user_data), dataset)
    puts "Saving #{hashed_tweet_data.length} tweets."
    puts "\n\n#{hashed_tweet_data.first.inspect}\n\n"
    # Tweet.import hashed_tweet_data.collect {|t| Tweet.new(t.merge({:dataset_id => dataset.id})) } if !hashed_tweet_data.empty?
    tweet_attrs = Tweet.new.attributes.keys - ["created_at", "updated_at", "id", "metadata_id", "instance_id", "scrape_id"]
    tweets_for_importing = []
    for tweet_hash in raw_tweets
      tweet = []
      
    Tweet.import()
    puts "Saving #{hashed_user_data.length} users."
    puts "\n\n#{hashed_tweet_data.first.inspect}\n\n"
    User.import hashed_user_data.collect {|u| User.new(u.merge({:dataset_id => dataset.id})) } if !hashed_user_data.empty?
  end
  
  
  ### STREAM FLOW ###
  
  def get_hashes(url)
    @current_data_count = 0
    @previous_data_count = 0
    collect_stream(STREAM_API_ADDRESS+url)
  end

  def collect_stream(url)
    EventMachine.run do
      EventMachine::add_periodic_timer(30) { check_for_lost_stream }
      EventMachine::add_periodic_timer(300) { adopt_new_requests }
      puts "Connection Started at #{Time.now} to URL #{url}"
      http = EventMachine::HttpRequest.new(url).get :head => { 'Authorization' => [ @username, @password ] }
      buffer = ""
      http.stream do |chunk|
        buffer += chunk
        # new: time check
        # puts "#{Time.now} : Time.at(@next_stop_time)"
        # times_up = (Time.now.to_f >= @next_stop_time)
        # puts "TimeCheck! result: #{times_up}"
        collect_data(buffer)
        EventMachine::stop_event_loop if U.times_up?(@next_stop_time)
      end
    end
  end

  def check_for_lost_stream
    puts
    puts "Checking for stopped stream."
    puts "previous_data_count: #{@previous_data_count}"
    puts "current_data_count: #{@current_data_count}"
    puts
    if @current_data_count == @previous_data_count
      EventMachine::stop_event_loop
      puts "Failed to update tweets in time period."
    else
      @previous_data_count = @current_data_count
      puts "Stream still connecting."
    end
    if @current_data_count >= MAX_ROW_COUNT_PER_BATCH
      EventMachine::stop_event_loop
    end
  end

  def adopt_new_requests
    # new:
    puts
    puts "Looking for new requests to adopt."
    puts
    datasets_added = add_datasets
    if datasets_added
      EventMachine::stop_event_loop
    end
  end

  def collect_data(buffer)
    while (line = buffer.slice!(/.+\r?\n/)) && !U.times_up?(@next_stop_time)
      if !line.nil? && !line.empty?
        @current_data_count += 1
        store(line)
      end
      line = nil
    end
  end

  def store(line)
    tweet = JSON.parse(line) rescue nil
    return if tweet.nil?
    stored = false
    case @type
    when "track"
      stored = store_track_tweets(tweet)
    when "sample"
      # This line was changed because flatify was moved to internal tweet parsing - Devin, May 19, 2010 @ 8:56pm
      # @end_data["sample"] << flatify(tweet)
      @end_data["sample"] << tweet
      stored = true
    end
    if stored
      # puts "\n\n"+"-"*100+"\n\n"+"Tweet stored: #{line}"+"\n\n"+"-"*100+"\n\n"
      puts "[tweet] #{tweet["user"]["screen_name"]}: #{tweet["text"]}" rescue "Error printing tweet."
    end
  end

  def store_track_tweets(tweet)
    # @end_data.each_pair do |key, dataset|
      if tweet["text"].nil?
        if !tweet["limit"].nil?
          puts "####################################WARNING####################################\n"
          puts "WE HAVE BEEN RATE LIMITED, AND HAVE LOST THIS MANY TWEETS AS A RESULT: #{tweet["limit"]["track"]}"
          puts "###################################/WARNING/###################################\n"
          sleep(SLEEP_CONSTANT)
        end
        return false
      else
        @end_data.each_key do |k|
          if tweet["text"].downcase.include?(key.downcase)
            @end_data[key] << tweet
            return true
          end
        end
      end
    # end
    
    # @end_data.each_pair do |key, dataset|
    #   if tweet["text"].nil?
    #     if !tweet["limit"].nil?
    #       puts "####################################WARNING####################################\n"
    #       puts "WE HAVE BEEN RATE LIMITED, AND HAVE LOST THIS MANY TWEETS AS A RESULT: #{tweet["limit"]["track"]}"
    #       puts "###################################/WARNING/###################################\n"
    #       sleep(SLEEP_CONSTANT)
    #     end
    #     return false
    #   else
    #     if tweet["text"].downcase.include?(key.downcase)
    #       @end_data[key] << tweet
    #       return true
    #     end
    #   end
    # end
  end
  
end


streamer = Streamer.new
streamer.stream