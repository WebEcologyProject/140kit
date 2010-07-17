class Worker
  
  require "#{ROOT_FOLDER}cluster-code/analyzer/analysis"
  require "#{ROOT_FOLDER}cluster-code/streamer/stream"
  require "#{ROOT_FOLDER}cluster-code/rester/rest"
    
  attr_accessor :instance_id, :hostname, :db, :scrape, :metadata, :stream_instance, :run_type, :rest_allowed, :rest_instance, :instance_name, :pid, :last_count_check, :tmp_path, :tmp_data, :killed

  def initialize(run_type)
    @db = Environment.db
    @run_type = run_type
    @hostname = `hostname`.strip
    @rest_allowed = Whitelisting.find({:hostname => @hostname}).nil? ? false : Whitelisting.find({:hostname => @hostname}).whitelisted
    @pid = Process.pid
    $w = self
    @tmp_data = {}
  end
  
  def poll
    check_in(AnalyticalInstance)
    while true
      killed = killed?(AnalyticalInstance)
      if !killed
        # begin
          AnalysisFlow.work
        # rescue => e        
        #   Failure.new({:message => "Error from Analytical instance #{$w.id} on machine #{@hostname} at #{Time.ntp}", :trace => "#{e}", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
        #   next
        # end
      else
        puts "I AM SLEEPING"
        sleep(SLEEP_CONSTANT)
      end
    end
    check_out(AnalyticalInstance)
  end
  
  def stream
    settings = {}
    check_in(StreamInstance)
    assign_user_account
    while true
      killed = killed?(StreamInstance)
      if !killed
        # begin
          StreamFlow.stream
        # rescue => e        
        #   Failure.new({:message => "Error from Stream instance #{$w.id} on machine #{@hostname} at #{Time.ntp}", :trace => "#{e}", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
        #   next
        # end
      else
        puts "I AM SLEEPING"
        sleep(SLEEP_CONSTANT)
      end
    end
    check_out(StreamInstance)
  end
  
  def rest
    check_in(RestInstance)
    @last_count_check = Time.now
    @rest_instance = Rest.new
    while true
      killed = killed?(RestInstance)
      if !killed
        # begin
          RestFlow.rest
        # rescue => e        
        #   Failure.new({:message => "Error from Rest instance #{$w.id} on machine #{@hostname} at #{Time.ntp}", :trace => "#{e}", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
        #   next
        # end
      else
        puts "I AM SLEEPING"
        sleep(SLEEP_CONSTANT)
      end
    end
  end
  
  def check_in(instance_type)
    w = instance_type.find({:hostname => self.hostname, :instance_name => self.instance_name})
    if w.class == instance_type
      self.instance_id = w.instance_id
      w.created_at = Time.ntp
      w.updated_at = Time.ntp
      w.pid = Process.pid
      w.slug = self.hostname.gsub(/[\.]/, "-")
      w.save
    else
      self.instance_id = Digest::SHA1.hexdigest(Time.ntp.to_s+rand(100000).to_s)
      w = instance_type.new({:instance_id => self.instance_id, :created_at => Time.ntp, :hostname => self.hostname, :instance_name => self.instance_name, :killed => false, :pid => Process.pid, :slug => self.hostname.gsub(/[\.]/, "-")})
      w.save
    end
    initialize_logged_session
  end
  
  def killed?(instance_type)
    instance_type.find({:hostname => self.hostname, :instance_name => self.instance_name}).killed
  end
  
  def check_out
    w = instance_type.find({:instance_id => self.instance_id, :hostname => self.hostname, :instance_name => self.instance_name})
    w.destroy
  end
   
  def initialize_logged_session
    File.new("../log/log_#{self.instance_id}.log", "w")
  end
  
  def assign_user_account
    user_assigned_to_instance = false
    while !user_assigned_to_instance
      twitter_account = AuthUser.find({:flagged => true, :instance_name => $w.instance_name, :hostname => $w.hostname})
      if twitter_account.nil?
        twitter_account = AuthUser.find({:flagged => false})
        if !twitter_account.nil?
          twitter_account.flagged = true
          twitter_account.instance_name = $w.instance_name
          twitter_account.hostname = $w.hostname
          twitter_account.save
          sleep(SLEEP_CONSTANT)
          if AuthUser.find({:user_name => twitter_account.user_name}).instance_name == $w.instance_name
            user_assigned_to_instance = true
            @stream_instance = Stream.new(twitter_account.user_name, twitter_account.password)
          elsif AuthUser.find_all({:flagged => true}).length == 0
            Failure.new({:message => "Error from Stream instance #{$w.id} on machine #{@hostname} at #{Time.ntp}", :trace => "Tried to assign AuthUser account when none were available", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
          end
        else
          puts "\nNo stream accounts are available!\n\n"
          Failure.new({:message => "Error from Stream instance #{$w.id} on machine #{@hostname} at #{Time.ntp}", :trace => "Tried to assign AuthUser account when none were available", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
        end
      else
        twitter_account.instance_name = $w.instance_name
        twitter_account.save
        user_assigned_to_instance = true
        @stream_instance = Stream.new(twitter_account.user_name, twitter_account.password)
      end
    end
  end
end