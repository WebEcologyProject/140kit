require 'rubygems'

require 'dm-core'
require 'dm-aggregates'
require 'dm-validations'

require 'extensions/dm-extensions'
require 'extensions/array'
require 'extensions/string'
require 'extensions/hash'
require 'extensions/time'
require 'extensions/date'

require 'models/instance'
require 'models/whitelisting'
require 'models/auth_user'
require 'models/lock'
require 'models/dataset'
require 'models/curation'
require 'models/tweet'
require 'models/user'

require 'utils/tweet_helper'
require 'utils/u'
require 'lib/tweetstream'

require 'eventmachine'
require 'em-http'
require 'json'

class Streamer < Instance

  MAX_TRACK_IDS = 10000
  BATCH_SIZE = 100
  STREAM_API_URL = "http://stream.twitter.com"
  CHECK_FOR_NEW_DATASETS_INTERVAL = 60*10
  
  attr_accessor :user_account, :username, :password, :start_time, :next_dataset_ends, :queue, :params, :datasets

  def initialize
    super
    self.instance_type = "streamer"
    @datasets = []
    @queue = []
    at_exit { do_at_exit }
  end
  
  def do_at_exit
    puts "Exiting."
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
      collect
      save_queue
      clean_up_datasets
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
  
  def collect
    puts "Collecting: #{params_for_stream.inspect}"
    client = TweetStream::Client.new(@username, @password, :yajl)
    client.add_periodic_timer(CHECK_FOR_NEW_DATASETS_INTERVAL) { puts "Checking for new datasets."; client.stop if add_datasets }
    client.on_limit { |skip_count| puts "\nWe are being rate limited! We lost #{skip_count} tweets!\n" }
    client.on_error { |message| puts "\nError: #{message}\n" }
    client.filter(params_for_stream) do |tweet|
      # puts tweet.inspect
      puts "[tweet] #{tweet[:user][:screen_name]}: #{tweet[:text]}"
      @queue << tweet
      save_queue if @queue.length >= BATCH_SIZE
      client.stop if U.times_up?(@next_dataset_ends)
    end
  end
  
  def params_for_stream
    params = {}
    @params.each {|k,v| params[k.to_sym] = v.collect {|x| x[:params] } }
    return params
  end
  
  def save_queue
    if !@queue.empty?
      puts "Saving #{@queue.length} tweets."
      tweets, users = tweets_and_users_from_queue
      @queue = []
      Thread.new { Tweet.save_all(tweets); User.save_all(users) }
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
  
  # def in_bounding_box?(location_params)
  #   t = self[:place][:bounding_box][:coordinates].first
  #   s = location_params.split(",").map {|c| c.to_f }
  #   a = { :left => t[0][0],
  #         :bottom => t[0][1],
  #         :right => t[2][0],
  #         :top => t[2][1] }
  #   b = { :left => s[0],
  #         :bottom => s[1],
  #         :right => s[2],
  #         :top => s[3] }
  #   abxdif = ((a[:left]+a[:right])-(b[:left]+b[:right])).abs
  #   abydif = ((a[:top]+a[:bottom])-(b[:top]+b[:bottom])).abs
  #   xdif = (a[:right]+b[:right])-(a[:left]+b[:left])
  #   ydif = (a[:top]+b[:top])-(a[:bottom]+b[:bottom])
  #   return (abxdif <= xdif && abydif <= ydif)
  # end
  
  def add_datasets
    datasets = Dataset.unlocked(:all, "scrape_finished = 0 AND (scrape_type='track' OR scrape_type='follow' OR scrape_type='locations')")
    return claim_new_datasets(datasets)
  end

  def claim_new_datasets(datasets)
    # distribute datasets evenly
    return false if datasets.empty?
    num_instances = Instance.count(:instance_type => "streamer", :killed => false)
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

  def update_next_dataset_ends
    update_start_times
    refresh_datasets # this is absolutely necessary even while it's called in update_start_times above. huh!
    soonest_ending_dataset = @datasets.sort {|x,y| (x.start_time.gmt + x.length - DateTime.now.gmt) <=> (y.start_time.gmt + y.length - DateTime.now.gmt) }.first
    @next_dataset_ends = soonest_ending_dataset.start_time.gmt + soonest_ending_dataset.length
  end

  def update_start_times
    refresh_datasets
    datasets_to_be_started = @datasets.select {|d| d.start_time.nil? }
    # Dataset.update_all({:start_time => DateTime.now.in_time_zone}, {:id => datasets_to_be_started.collect {|d| d.id}})
    Dataset.all(:id => datasets_to_be_started.collect {|d| d.id}).update(:start_time => DateTime.now)
    refresh_datasets
  end

  def refresh_datasets
    @datasets = Dataset.all(:id => @datasets.collect {|d| d.id })
  end

  def clean_up_datasets
    started_datasets = @datasets.reject {|d| d.start_time.nil? }
    finished_datasets = started_datasets.select {|d| U.times_up?(d.start_time.gmt+d.length) }
    if !finished_datasets.empty?
      puts "Finished collecting "+finished_datasets.collect {|d| "#{d.scrape_type}:\"#{d.params}\"" }.join(", ")
      # Dataset.update_all({:scrape_finished => true}, {:id => finished_datasets.collect {|d| d.id}})
      Dataset.all(:id => finished_datasets.collect {|d| d.id}).update(:scrape_finished => true)
      @datasets -= finished_datasets
      unlock_all(finished_datasets)
    end
  end
  
end

streamer = Streamer.new
streamer.stream