require 'models/whitelisting'
require 'models/lock'
# require 'YAML'

class Instance
  include DataMapper::Resource
  property :id,             Serial
  property :instance_id,    String, :length => 40
  property :hostname,       String
  property :pid,            Integer
  property :killed,         Boolean
  property :instance_type,  String
  
  # validates_presence_of :instance_type
  # validates_presence_of :instance_id
  # validates_uniqueness_of :instance_id
  
  attr_accessor :metadata, :rest_allowed, :last_count_check, :tmp_path, :tmp_data, :check_in_thread

  def initialize
    super
    connect_to_db
    self.hostname = `hostname`.strip
    self.rest_allowed = whitelisted?
    self.pid = Process.pid
    self.tmp_data = {}
    self.instance_id = Digest::SHA1.hexdigest("#{self.hostname}#{self.pid}")
    puts "Hello, my name is #{self.instance_id}."
  end
  
  def connect_to_db
    env = ARGV.first || "development"
    db = YAML.load(File.read('database.yml'))
    if !db.has_key?(env)
      puts "No such environment #{env}."
      env = "development"
    end
    puts "Booting #{env} environment."
    db = db[env]
    DataMapper.finalize
    DataMapper.setup(:default, "#{db["adapter"]}://#{db["username"]}:#{db["password"]}@#{db["host"]}/#{db["database"]}")
  end
  
  def check_in
    @check_in_thread = Thread.new { loop { self.touch; sleep(CHECK_IN_FREQUENCY*60) } }
  end
  
  def whitelisted?
    # return Whitelisting.first(:conditions => {:hostname => self.hostname}).nil? ? false : Whitelisting.first(:conditions => {:hostname => self.hostname}).whitelisted
    wl = Whitelisting.first(:hostname => self.hostname)
    return false if wl.nil?
    return Whitelisting.first(:hostname => self.hostname).whitelisted
  end
  
  def lock_all(objects)
    # returns array of successfully locked objects
    return objects.collect {|o| o if lock(o) }.compact
  end
  
  def lock(obj)
    lock = Lock.new(:classname => obj.class.to_s, :with_id => obj.id, :instance_id => self.instance_id)
    return lock.save
  end
  
  def unlock_all(objects)
    objects.each {|o| unlock(o) }
  end
  
  def unlock(obj)
    lock = Lock.first(:classname => obj.class.to_s, :with_id => obj.id, :instance_id => self.instance_id)
    lock.destroy if !lock.nil?
  end
  
  def killed?
    self.killed
  end
  
  def locks
    Lock.all(:instance_id => self.instance_id)
  end
  
  def destroy_locks
    Lock.all(:instance_id => self.instance_id).destroy
  end
  
end