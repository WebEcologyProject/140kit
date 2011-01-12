CHECK_IN_FREQUENCY = 5 # minutes

class Instance < ActiveRecord::Base
  
  validates_presence_of :instance_type
  validates_presence_of :instance_id
  validates_uniqueness_of :instance_id
  
  attr_accessor :metadata, :rest_allowed, :last_count_check, :tmp_path, :tmp_data, :check_in_thread

  def initialize
    super
    self.hostname = `hostname`.strip
    self.rest_allowed = whitelisted?
    self.pid = Process.pid
    self.tmp_data = {}
    self.instance_id = Digest::SHA1.hexdigest("#{self.hostname}#{self.pid}")
    puts "Hello, my name is #{self.instance_id}."
  end
  
  def check_in
    @check_in_thread = Thread.new { loop { self.touch; sleep(CHECK_IN_FREQUENCY*60) } }
  end
  
  def whitelisted?
    return Whitelisting.first(:conditions => {:hostname => self.hostname}).nil? ? false : Whitelisting.first(:conditions => {:hostname => self.hostname}).whitelisted
  end
  
  def lock_all(objects)
    # returns array of successfully locked objects
    return objects.collect {|o| o if lock(o) }.compact
  end
  
  def lock(obj)
    lock = Lock.new({:classname => obj.class.to_s, :with_id => obj.id, :instance_id => self.instance_id})
    return lock.save
  end
  
  def unlock_all(objects)
    objects.each {|o| unlock(o) }
  end
  
  def unlock(obj)
    lock = Lock.first(:conditions => {:classname => obj.class.to_s, :with_id => obj.id, :instance_id => self.instance_id})
    lock.destroy if !lock.nil?
  end
  
  def killed?
    self.killed
  end
  
end
