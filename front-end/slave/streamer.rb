# require File.dirname(__FILE__)+'/../lib/active_record_extensions'
# require File.dirname(__FILE__)+'/worker'
# require File.dirname(__FILE__)+'/utils/user_helper'
require File.dirname(__FILE__)+'/utils/tweet_helper'
require File.dirname(__FILE__)+'/utils/u'
require File.dirname(__FILE__)+'/utils/crewait'
require File.dirname(__FILE__)+'/lib/tweetstream'

require 'eventmachine'
require 'em-http'
require 'json'

class Streamer < Instance

  MAX_TRACK_IDS = 10000
  MAX_ROW_COUNT_PER_BATCH = 100
  STREAM_API_URL = "http://stream.twitter.com"
  CHECK_FOR_NEW_DATASETS_INTERVAL = 60*10
  
  attr_accessor :user_account, :username, :password, :start_time, :next_dataset_ends, :queue, :params, :datasets
  
  ## MOVE ME ##
  # def screenname(user_id); return JSON.parse(open("http://api.twitter.com/1/users/show.json?user_id=#{user_id}").read)['screen_name'] rescue nil; end
  def user_id(screenname); return JSON.parse(open("http://api.twitter.com/1/users/show.json?screen_name=#{screenname}").read)['id'] rescue nil; end
  #############
  
  def initialize
    super
    self.instance_type = "streamer"
    @datasets = []
    @queue = []
    at_exit { do_at_exit }
  end
  
  def do_at_exit
    save_queue
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
    clean_up_datasets
    if !@datasets.empty?
      update_next_dataset_ends
      update_params
      collect#(filter_url)
      save_queue
      clean_up_datasets
    end
  end

  # def collect(url)
  #   EventMachine.run do
  #     # EventMachine::add_periodic_timer(60) { adopt_new_requests }
  #     EventMachine::add_periodic_timer(60) { adopt_new_requests; save_queue_or_renew_connection }
  #     next_stop_timer = @next_stop_time.to_i-DateTime.now.to_f.to_i
  #     next_stop_timer = 0 if next_stop_timer < 0
  #     EventMachine::add_timer(next_stop_timer) { EventMachine::stop_event_loop }
  #     http = EventMachine::HttpRequest.new(url).get :head => { 'Authorization' => [ @username, @password ] }
  #     buffer = ""
  #     puts "Connecting to stream: #{url}"
  #     http.stream do |chunk|
  #       buffer += chunk
  #       # while line = buffer.slice!(/.+\r?\n/)
  #       #   # tweet = JSON.parse(line) rescue nil
  #       #   # add_to_queue(tweet) if tweet.nil?
  #       #   add_to_queue(JSON.parse(line))
  #       # end
  #       print chunk
  #     end
  #   end
  # end
  
  def collect
    puts "Collecting: #{params_for_stream.inspect}"
    # @next_check_for_new_datasets = DateTime.now.in_time_zone + CHECK_FOR_NEW_DATASETS_INTERVAL
    # puts "Next check for new datasets: #{@next_check_for_new_datasets.inspect}"
    client = TweetStream::Client.new(@username, @password, :yajl)
    client.add_periodic_timer(CHECK_FOR_NEW_DATASETS_INTERVAL) { puts "Checking for new datasets."; client.stop if add_datasets }
    client.on_limit { |skip_count| puts "\nWe are being rate limited! We lost #{skip_count} tweets!\n" }
    client.on_error { |message| puts "\nError: #{message}\n" }
    client.filter(params_for_stream) do |tweet|
      # puts tweet.inspect
      puts "[tweet] #{tweet[:user][:screen_name]}: #{tweet[:text]}"
      @queue << tweet
      save_queue if @queue.length >= MAX_ROW_COUNT_PER_BATCH
      client.stop if U.times_up?(@next_dataset_ends)
      # puts "#{DateTime.now.in_time_zone.inspect} <=> #{@next_check_for_new_datasets}"
      # if U.times_up?(@next_check_for_new_datasets)
      #   puts "Checking for new datasets."
      #   if add_datasets
      #     puts "Adding new datasets."
      #     client.stop
      #   else
      #     @next_check_for_new_datasets = DateTime.now.in_time_zone + CHECK_FOR_NEW_DATASETS_INTERVAL
      #   end
      # end
    end
    
  end
  
  # def filter_url
  #   param_strings = []
  #   @params.each do |k,v|
  #     param_string = "#{k}="
  #     param_string += v.collect {|h| h[:params] }.join(",")
  #     param_strings << param_string
  #   end
  #   "http://stream.twitter.com/1/statuses/filter.json?#{param_strings.join('&')}"
  # end
  
  def params_for_stream
    params = {}
    @params.each {|k,v| params[k.to_sym] = v.collect {|x| x[:params] } }
    return params
  end
  
  # def save_queue_or_renew_connection
  #   if @queue.empty?
  #     puts "Haven't gotten tweets in a while. Renewing connection."
  #     EventMachine::stop_event_loop
  #   else
  #     save_queue
  #   end
  # end
  
  # def add_to_queue(tweet)
  #   if tweet['text']
  #     puts "[tweet] #{tweet['user']['screen_name']}: #{tweet['text']}"
  #     @queue << tweet
  #   end
  # end
  
  def save_queue
    if !@queue.empty?
      puts "Saving #{@queue.length} tweets."
      tweets, users = tweets_and_users_from_queue
      while !tweets.empty? && !users.empty?
        tmp_tweets = tweets.slice!(0,MAX_ROW_COUNT_PER_BATCH-1)
        tmp_users = users.slice!(0,MAX_ROW_COUNT_PER_BATCH-1)
        Crewait.start_waiting
        tmp_tweets.each {|tweet| Tweet.crewait(tweet) }
        tmp_users.each {|user| User.crewait(user) }
        Crewait.go!("replace")
      end
      @queue = []
    end
  end
  
  def tweets_and_users_from_queue
    tweets = []
    users = []
    @queue.each do |json|
      tweet, user = TweetHelper.prepped_tweet_and_user(json)
      dataset_id = {:dataset_id => determine_dataset(json)}
      tweets << tweet.merge(dataset_id)
      users << user.merge(dataset_id)
    end
    tweets.uniq! {|t| t[:twitter_id] }
    users.uniq! {|u| u[:twitter_id] }
    return tweets, users
  end
  
  def update_params
    @params = {}
    for d in @datasets
      if @params[d.scrape_type]
        @params[d.scrape_type] << {:params => d.params, :dataset_id => d.id}
      else
        @params[d.scrape_type] = [{:params => d.params, :dataset_id => d.id}]
      end
    end
  end
  
  def determine_dataset(tweet)
    return @datasets.first.id if @datasets.length == 1
    if @params.has_key?("locations")
      if tweet[:place]
        for location in @params["locations"]
          if in_location?(location[:params], tweet[:place][:bounding_box][:coordinates].first)
            return location[:dataset_id]
          end
        end
      end
    end
    if @params.has_key?("track")
      for term in @params["track"]
        if tweet[:text].include?(term[:params])
          return term[:dataset_id]
        end
      end
    end
    if @params.has_key?("follow")
      for user_id in @params["follow"]
        if tweet[:user][:id] == user_id[:params].to_i
          return user_id[:dataset_id]
        end
      end
    end
    return nil
  end
  
  def in_location?(location_params, tweet_location)
    search_location = location_params.split(",").map {|c| c.to_i }
    t_longs = tweet_location.collect {|a| a[0] }.uniq.sort
    t_lats = tweet_location.collect {|a| a[0] }.uniq.sort
    t_long_range = (t_longs.first..t_longs.last)
    t_lat_range = (t_lats.first..t_lats.last)
    l_long_range = (search_location[0]..search_location[2])
    l_lat_range = (search_location[1]..search_location[3])
    return (l_long_range.include?(t_long_range) && l_lat_range.include?(t_lat_range))
  end
  
  # def adopt_new_requests
  #   puts "Looking for new requests to adopt."
  #   datasets_added = add_datasets
  #   if datasets_added
  #     EventMachine::stop_event_loop
  #   end
  # end
  
  def add_datasets
    datasets = Dataset.unlocked(:all, "scrape_finished = 0 AND (scrape_type='track' OR scrape_type='follow' OR scrape_type='locations')")
    return claim_new_datasets(datasets)
  end

  def claim_new_datasets(datasets)
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

  def update_next_dataset_ends
    update_start_times
    refresh_datasets # this is absolutely necessary even while it's called in update_start_times above. huh!
    soonest_ending_dataset = @datasets.sort {|x,y| (x.start_time + x.length - DateTime.now.in_time_zone) <=> (y.start_time + y.length - DateTime.now.in_time_zone) }.first
    @next_dataset_ends = soonest_ending_dataset.start_time.in_time_zone + soonest_ending_dataset.length
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
    started_datasets = @datasets.reject {|d| d.start_time.nil? }
    finished_datasets = started_datasets.select {|d| U.times_up?(d.start_time+d.length) }
    if !finished_datasets.empty?
      puts "Finished collecting "+finished_datasets.collect {|d| "#{d.scrape_type}:\"#{d.params}\"" }.join(", ")
      Dataset.update_all({:scrape_finished => true}, {:id => finished_datasets.collect {|d| d.id}})
      @datasets -= finished_datasets
    end
  end
  
  # def stream_data
  #   # new:
  #   track_terms = @datasets.collect {|d| d.term.sanitize_for_streaming }.compact.uniq # sanitize terms here???
  #   actual_terms = @datasets.collect {|d| d.term }.compact.uniq
  #   @start_time, @length = determine_timer_values
  #   # "counter" doesn't seem like a very appropriate name.
  #   # simpler solution for stop times:
  #   @next_stop_time = @start_time + @length
  #   puts "First dataset stops at #{@next_stop_time}."
  #   track(track_terms, actual_terms)
  # end
  
###REQUEST TYPES###

  # def track(track_terms, actual_terms)
  #   puts "Tracking #{track_terms.join(", ")}."
  #   #Pull is just search data, and should look like ["lol", "haha"] etc or ["lol"] for only one term
  #   #http://#{HOSTNAME}/1/statuses/filter.json?track="lol"
  #   @type = "track"
  #   @params = actual_terms
  #   base_url = "/1/statuses/filter.json?#{@type}="
  #   parameterized_call(base_url, track_terms, actual_terms)
  # end
  # 
  # def sample
  #   #Sample is a smattering of all tweets
  #   @type = "sample"
  #   @params = nil
  #   @timer = Time.now.to_i+@length
  #   @end_data["sample"] = []
  #   base_url = "/1/statuses/sample.json"
  #   StreamFlow.get_hashes(base_url)
  #   g = ""
  #   store_to_db
  #   clean_up_metadatas
  # end
  
###FLOW TYPES###
  
  # def parameterized_call(base_url, track_terms, actual_terms)
  #   track_terms.collect!{ |param| param = param.class == Array ? param.join(",") : param }
  #   actual_terms.each do |param|
  #     @end_data[param] = []
  #   end
  #   get_hashes(base_url+track_terms.join(",")) if track_terms.length > 0
  #   store_to_db
  #   clean_up_datasets
  # end
  
###DB PREP METHODS### 

  # def store_to_db
  #   @datasets.each do |dataset|
  #     @end_data.each_pair do |term, tweets|
  #       if dataset.term == term
  #         db_save(dataset, tweets)
  #       end
  #     end
  #   end
  # end
  
  # def db_save(dataset, tweets)
  #   # This line was changed because flatify was moved to internal tweet parsing - Devin, May 19, 2010 @ 8:56pm
  #   # The line commented is exactly the same as the following line - Ian, October 7, 2010 @ 9:01pm
  #   # raw_tweets = tweets.collect{|t| t.flatify}
  #   raw_tweets = tweets.collect{|t| t.flatify}
  #   raw_users = tweets.collect {|u| u["user"]}
  #   # hashed_tweet_data = TweetHelper.hash_tweets(raw_tweets)[:tweets]
  #   # hashed_user_data = UserHelper.hash_users(raw_users)[:users]
  #   # U.append_and_save(hashed_tweet_data.merge(hashed_user_data), dataset)
  #   puts "Saving #{hashed_tweet_data.length} tweets."
  #   puts "\n\n#{hashed_tweet_data.first.inspect}\n\n"
  #   # Tweet.import hashed_tweet_data.collect {|t| Tweet.new(t.merge({:dataset_id => dataset.id})) } if !hashed_tweet_data.empty?
  #   tweet_attrs = Tweet.new.attributes.keys - ["created_at", "updated_at", "id", "metadata_id", "instance_id", "scrape_id"]
  #   # tweets_for_importing = []
  #   # for tweet_hash in raw_tweets
  #   #   tweet = []
  #   #   
  #   Tweet.import()
  #   puts "Saving #{hashed_user_data.length} users."
  #   puts "\n\n#{hashed_tweet_data.first.inspect}\n\n"
  #   User.import hashed_user_data.collect {|u| User.new(u.merge({:dataset_id => dataset.id})) } if !hashed_user_data.empty?
  # end
  
  
  ### STREAM FLOW ###
  
  # def get_hashes(url)
  #   @current_data_count = 0
  #   @previous_data_count = 0
  #   collect_stream(STREAM_API_URL+url)
  # end

  # def collect_stream(url)
  #   EventMachine.run do
  #     EventMachine::add_periodic_timer(30) { check_for_lost_stream }
  #     EventMachine::add_periodic_timer(300) { adopt_new_requests }
  #     puts "Connection Started at #{Time.now} to URL #{url}"
  #     http = EventMachine::HttpRequest.new(url).get :head => { 'Authorization' => [ @username, @password ] }
  #     buffer = ""
  #     http.stream do |chunk|
  #       buffer += chunk
  #       # new: time check
  #       # puts "#{Time.now} : Time.at(@next_stop_time)"
  #       # times_up = (Time.now.to_f >= @next_stop_time)
  #       # puts "TimeCheck! result: #{times_up}"
  #       collect_data(buffer)
  #       EventMachine::stop_event_loop if U.times_up?(@next_stop_time)
  #     end
  #   end
  # end

  # def check_for_lost_stream
  #   puts
  #   puts "Checking for stopped stream."
  #   puts "previous_data_count: #{@previous_data_count}"
  #   puts "current_data_count: #{@current_data_count}"
  #   puts
  #   if @current_data_count == @previous_data_count
  #     EventMachine::stop_event_loop
  #     puts "Failed to update tweets in time period."
  #   else
  #     @previous_data_count = @current_data_count
  #     puts "Stream still connecting."
  #   end
  #   if @current_data_count >= MAX_ROW_COUNT_PER_BATCH
  #     EventMachine::stop_event_loop
  #   end
  # end

  # def collect_data(buffer)
  #   while (line = buffer.slice!(/.+\r?\n/)) && !U.times_up?(@next_stop_time)
  #     if !line.nil? && !line.empty?
  #       @current_data_count += 1
  #       store(line)
  #     end
  #     line = nil
  #   end
  # end

  # def store(line)
  #   tweet = JSON.parse(line) rescue nil
  #   return if tweet.nil?
  #   stored = false
  #   case @type
  #   when "track"
  #     stored = store_track_tweets(tweet)
  #   when "sample"
  #     # This line was changed because flatify was moved to internal tweet parsing - Devin, May 19, 2010 @ 8:56pm
  #     # @end_data["sample"] << flatify(tweet)
  #     @end_data["sample"] << tweet
  #     stored = true
  #   end
  #   if stored
  #     # puts "\n\n"+"-"*100+"\n\n"+"Tweet stored: #{line}"+"\n\n"+"-"*100+"\n\n"
  #     puts "[tweet] #{tweet["user"]["screen_name"]}: #{tweet["text"]}" rescue "Error printing tweet."
  #   end
  # end

  # def store_track_tweets(tweet)
  #   # @end_data.each_pair do |key, dataset|
  #     if tweet["text"].nil?
  #       if !tweet["limit"].nil?
  #         puts "####################################WARNING####################################\n"
  #         puts "WE HAVE BEEN RATE LIMITED, AND HAVE LOST THIS MANY TWEETS AS A RESULT: #{tweet["limit"]["track"]}"
  #         puts "###################################/WARNING/###################################\n"
  #         sleep(SLEEP_CONSTANT)
  #       end
  #       return false
  #     else
  #       @end_data.each_key do |k|
  #         if tweet["text"].downcase.include?(key.downcase)
  #           @end_data[key] << tweet
  #           return true
  #         end
  #       end
  #     end
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
  # end
  
end


streamer = Streamer.new
streamer.stream