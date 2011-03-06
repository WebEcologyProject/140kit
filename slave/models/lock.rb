class Lock
  include DataMapper::Resource
  property :id, Serial
  property :classname, String
  property :with_id, Integer
  property :instance_id, String#, :length => 40
  validates_uniqueness_of :with_id, :scope => :classname
end

module Locking
  module ClassMethods
    def locked(opts=:all, where="")
      table = self.to_s.to_table
      where = " AND #{where}" if !where.empty?
      sql = "SELECT id FROM `#{table}` WHERE (`#{table}`.`id` IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{self.to_s}')#{where})"
      sql += " ORDER BY id DESC LIMIT 1" if opts == :last
      sql += " ORDER BY id ASC LIMIT 1" if opts == :first
      result = repository(:default).adapter.select(sql)
      # return opts == :all ? objects_from(result) : object_from(result.first)
      return opts == :all ? self.all(:id => result) : self.get(result.first)
    end
  
    def unlocked(opts=:all, where="")
      table = self.to_s.to_table
      where = " AND #{where}" if !where.empty?
      sql = "SELECT id FROM `#{table}` WHERE (`#{table}`.`id` NOT IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{self.to_s}')#{where})"
      sql += " ORDER BY id DESC LIMIT 1" if opts == :last
      sql += " ORDER BY id ASC LIMIT 1" if opts == :first
      result = repository(:default).adapter.select(sql)
      # return opts == :all ? objects_from(result) : object_from(result.first)
      return opts == :all ? self.all(:id => result) : self.get(result.first)
    end
  
    # protected
    #   
    # def object_from(struct)
    #   return nil if struct.nil?
    #   attrs = self.properties.collect {|p| p.name.to_s }
    #   hash = {}
    #   struct.members.each_index {|i| hash[struct.members[i]] = struct.values[i] if attrs.include?(struct.members[i]) }
    #   return self.new(hash)
    # end
    #   
    # def objects_from(structs)
    #   return [] if structs.empty?
    #   attrs = self.properties.collect {|p| p.name.to_s }
    #   objs = []
    #   for struct in structs
    #     hash = {}
    #     struct.members.each_index {|i| hash[struct.members[i]] = struct.values[i] if attrs.include?(struct.members[i]) }
    #     objs << self.new(hash)
    #   end
    #   return objs
    # end
  end
  
  module InstanceMethods
    def unlock!
      # obj.unlock!
      # to be used for debugging mainly
      lock = Lock.first(:classname => self.class.to_s, :with_id => self.id)
      lock.nil? ? true : lock.destroy
    end
  end
  
end

DataMapper::Model.append_extensions(Locking::ClassMethods)
DataMapper::Model.append_inclusions(Locking::InstanceMethods)