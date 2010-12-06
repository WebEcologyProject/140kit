module StreamFlow

  attr_accessor :stream

  def self.stream
    Scheduler.add_stream_datasets
    # if $w.stream_instance.metadatas.length > 0
    if !$w.stream_instance.datasets.empty?
      $w.stream_instance.stream_data
    else
      puts "No stream datasets found to track at this time."
    end
  end
  
  def self.get_hashes(url)
    @stream = $w.stream_instance
    @stream.current_data_count = 0
    @stream.previous_data_count = 0
    self.collect_stream(HOSTNAME+url)
  end

  def self.collect_stream(url)
    EventMachine.run do
      EventMachine::add_periodic_timer(30) { self.check_for_lost_stream }
      EventMachine::add_periodic_timer(300) { self.adopt_new_requests }
      request_start = Time.ntp.to_i
      puts "Connection Started at #{Time.at(request_start)} to URL #{url}"
      http = EventMachine::HttpRequest.new(url).get :head => { 'Authorization' => [ @stream.username, @stream.password ] }
      buffer = ""
      http.stream do |chunk|
        buffer += chunk
        # new: time check
        times_up = (Time.ntp.to_f >= @stream.next_stop_time)
        puts "TimeCheck! result: #{times_up}"
        self.collect_data(buffer)
        EventMachine::stop_event_loop if times_up # U.times_up(@stream.length, @stream.counter)
      end
    end
  end

  def self.check_for_lost_stream
    puts "########CHECK FOR STOPPED STREAM########"
    puts "previous_data_count: #{@stream.previous_data_count}"
    puts "current_data_count: #{@stream.current_data_count}"
    if @stream.current_data_count == @stream.previous_data_count
      EventMachine::stop_event_loop
      puts "########FAILED TO UPDATE TWEETS IN TIME PERIOD########"
    else
      @stream.previous_data_count = @stream.current_data_count
      puts "########STREAM STILL COLLECTING########"
    end
    if @stream.current_data_count >= MAX_ROW_COUNT_PER_BATCH
      EventMachine::stop_event_loop
    end
  end

  def self.adopt_new_requests
    # new:
    puts "########LOOKING FOR NEW REQUESTS TO ADOPT########"
    datasets_added = Scheduler.add_stream_datasets
    if datasets_added
      EventMachine::stop_event_loop
    end
    
    # old:
    # metadatas = Scrape.find_all({:scrape_finished => false}).collect{|scrape| scrape.metadatas}
    # metadatas = metadatas.flatten.compact
    # metadatas = metadatas.select {|m| (m.instance_id.nil? || m.instance_id.empty?)}
    # new_metdatas_added = Scheduler.claim_metadata(metadatas, StreamInstance)
    # if new_metadatas_added
    #   EventMachine::stop_event_loop
    # end
  end

  def self.collect_data(buffer)
    while (line = buffer.slice!(/.+\r?\n/)) && !U.times_up(@stream.length, @stream.counter)
      if !line.nil? && !line.empty?
        puts "Recieved Tweet..."
        @stream.current_data_count += 1
        self.store(line)
      end
      line = nil
    end
  end

  def self.store(line)
    tweet = JSON.parse(line) rescue nil
    return if tweet.nil?
    stored = false
    case @stream.type
    when "track"
      stored = self.store_track_tweets(tweet)
    when "sample"
      # This line was changed because flatify was moved to internal tweet parsing - Devin, May 19, 2010 @ 8:56pm
      # @stream.end_data["sample"] << flatify(tweet)
      @stream.end_data["sample"] << tweet
      stored = true
    end
    if stored
      puts "\n\n"+"-"*100+"\n\n"+"Tweet stored: #{line}"+"\n\n"+"-"*100+"\n\n"
    end
  end

  def self.store_track_tweets(tweet)
    @stream.end_data.each_pair do |key, dataset|
      if tweet["text"].nil?
        if !tweet["limit"].nil?
          puts "####################################WARNING####################################\n"
          puts "WE HAVE BEEN RATE LIMITED, AND HAVE LOST THIS MANY TWEETS AS A RESULT: #{tweet["limit"]["track"]}"
          puts "###################################/WARNING/###################################\n"
          sleep(SLEEP_CONSTANT)
        end
        return false
      else
        if tweet["text"].downcase.include?(key.downcase)
          @stream.end_data[key] << tweet
          return true
        end
      end
    end
  end
  
end
