

class Worker
    
  attr_accessor :instance, :instance_id, :hostname, :db, :scrape, :metadata, :run_type, :rest_allowed, :instance_name, :pid, :last_count_check, :tmp_path, :tmp_data, :killed

  def initialize(run_type)
    @run_type = run_type
    @hostname = `hostname`.strip
    @rest_allowed = whitelisted?
    @pid = Process.pid
    # $w = self
    @tmp_data = {}
  end
  
  def update_instance
    
  end
  
  def whitelisted?
    return Whitelisting.first(:conditions => {:hostname => @hostname}).nil? ? false : Whitelisting.first(:conditions => {:hostname => @hostname}).whitelisted
  end
  
  def lock_all(objects)
    # returns array of successfully locked objects
    return objects.collect {|o| o if lock(o) }.compact
  end
  
  def lock(obj)
    lock = Lock.new({:classname => obj.class.to_s, :with_id => obj.id, :instance_id => @instance_id})
    return lock.save
  end
  
  def unlock_all(objects)
    objects.each {|o| unlock(o) }
  end
  
  def unlock(obj)
    lock = Lock.first(:conditions => {:classname => obj.class.to_s, :with_id => obj.id, :instance_id => @instance_id})
    lock.destroy if !lock.nil?
  end
  
  # def poll
  #   check_in("analysis")
  #   while true
  #     if !killed?
  #       # begin
  #         AnalysisFlow.work
  #       # rescue => e
  #       #   Failure.new({:message => "Error from Analytical instance #{$w.id} on machine #{@hostname} at #{Time.ntp}", :trace => "#{e}", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
  #       #   next
  #       # end
  #     else
  #       puts "I AM SLEEPING"
  #       sleep(SLEEP_CONSTANT)
  #     end
  #   end
  #   check_out(AnalyticalInstance)
  # end
  # 
  # def stream
  #   settings = {}
  #   check_in("stream")
  #   assign_user_account
  #   while true
  #     if !killed?
  #       # begin
  #         StreamFlow.stream
  #       # rescue => e        
  #       #   Failure.new({:message => "Error from Stream instance #{$w.id} on machine #{@hostname} at #{Time.ntp}", :trace => "#{e}", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
  #       #   next
  #       # end
  #     else
  #       puts "I AM SLEEPING"
  #       sleep(SLEEP_CONSTANT)
  #     end
  #   end
  #   # this will never ever be called:
  #   check_out
  # end
  # 
  # def rest
  #   check_in(RestInstance)
  #   @last_count_check = Time.now
  #   @rest_instance = Rest.new
  #   while true
  #     killed = killed?(RestInstance)
  #     if !killed
  #       # begin
  #         RestFlow.rest
  #       # rescue => e        
  #       #   Failure.new({:message => "Error from Rest instance #{$w.id} on machine #{@hostname} at #{Time.ntp}", :trace => "#{e}", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
  #       #   next
  #       # end
  #     else
  #       puts "I AM SLEEPING"
  #       sleep(SLEEP_CONSTANT)
  #     end
  #   end
  # end
  
  # def check_in(instance_type)
  #   
  #   # new:
  #   # AnalyticalInstance, RestInstance, StreamInstance are now just Instances with instance_types
  #   
  #   @instance = Instance.first(:conditions => {:hostname => @hostname, :instance_name => @instance_name})
  #   if @instance.nil?
  #     @instance_id = Digest::SHA1.hexdigest(Time.now.to_s+rand(100000).to_s)
  #     @instance = Instance.new({:instance_id => @instance_id, :hostname => @hostname, :instance_name => @instance_name, :killed => false, :pid => Process.pid, :slug => @hostname.gsub(/[\.]/, "-"), :instance_type => instance_type})
  #     @instance.save
  #   else
  #     @instance_id = i.instance_id
  #     @instance.pid = Process.pid
  #     @instance.slug = @hostname.gsub(/(\W+)/, "-")
  #     @instance.save
  #   end
  #   # initialize_logged_session
  # end
  
  def killed?
    @killed
  end
  
  # def check_out
  #   i = Instance.find({:instance_id => @instance_id, :hostname => @hostname, :instance_name => @instance_name})
  #   i.destroy
  # end
  #  
  # def initialize_logged_session
  #   File.new("../log/log_#{self.instance_id}.log", "w")
  # end
  
end