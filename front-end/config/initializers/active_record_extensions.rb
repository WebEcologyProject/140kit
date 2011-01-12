class ActiveRecord::Base
  
  def self.locked(opts=:all, where="")
    # self.find(:all, :joins => "LEFT JOIN `locks` ON `#{self.to_s.to_table}`.`id` = `locks`.`with_id`", :conditions => ["`locks`.`classname` = ? AND `locks`.`with_id` IS NOT NULL", self.to_s])
    table = self.to_s.to_table
    where = " AND #{where}" if !where.empty?
    sql = "SELECT * FROM `#{table}` WHERE (`#{table}`.`id` IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{self.to_s}')#{where})"
    sql += " LIMIT 1" if opts == :first
    result = self.find_by_sql(sql)
    return opts == :first ? result.first : result
  end
  
  def self.unlocked(opts=:all, where="")
    # self.find(:all, :joins => "LEFT JOIN `locks` ON `#{self.to_s.to_table}`.`id` = `locks`.`with_id`", :conditions => ["`locks`.`classname` = ? AND `locks`.`with_id` IS NULL", self.to_s])
    table = self.to_s.to_table
    where = " AND #{where}" if !where.empty?
    sql = "SELECT * FROM `#{table}` WHERE (`#{table}`.`id` NOT IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{self.to_s}')#{where})"
    sql += " LIMIT 1" if opts == :first
    result = self.find_by_sql(sql)
    return opts == :first ? result.first : result
  end
  
  # def self.unlocked
  #   # table = self.to_s.to_table
  #   # sql = self.send(:construct_finder_sql, opts)
  #   # where = sql.scan(/WHERE \(([^\(]*)\)/).first
  #   # if where.nil?
  #   #   sql += " WHERE (`#{table}`.`id` NOT IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{self.to_s}'))"
  #   # else
  #   #   sql.gsub(where[0], "where[0] AND `#{table}`.`id` NOT IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{classname.to_s}')" )
  #   #   sql += "`#{table}`.`id` NOT IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{classname.to_s}')"
  #   # end
  #   # puts sql
  #   # "`#{table}`.`id` NOT IN (SELECT `locks`.`with_id` FROM `locks` WHERE `locks`.`classname` = '#{classname.to_s}')"
  #   # self.connection.select_values(sql)
  #   # where = [where] if where.class.to_s == "String"
  #   # table = self.to_s.underscore
  #   # where << "id NOT IN (SELECT with_id FROM locks WHERE classname = '#{classname.to_s}')"
  #   # where = " WHERE "+where.join(" AND ")
  #   # result = self.result("SELECT * FROM #{table} #{where}")
  #   # objs = result.collect {|o| classname.new(o) }
  #   # return objs
  #   # "SELECT * FROM `#{table}` LEFT OUTER JOIN `locks` ON `#{table}`.`with_id` = `locks`.`with_id` WHERE `locks`.`classname` = '#{classname.to_s}' AND `locks`.`with_id` IS NULL"
  # end
  # 
  # def self.locked
  #   self.find(:all, :joins => "LEFT JOIN `locks` ON `#{self.to_s.to_table}`.`id` = `locks`.`with_id`", :conditions => ["`locks`.`classname` = ? AND `locks`.`with_id` IS NOT NULL", self.to_s])
  #   # where = [where] if where.class.to_s == "String"
  #   # table = self.to_s.underscore
  #   # where << "id IN (SELECT with_id FROM locks WHERE classname = '#{classname.to_s}')"
  #   # where = " WHERE "+where.join(" AND ")
  #   # result = self.result("SELECT * FROM #{table} #{where}")
  #   # objs = result.collect {|o| classname.new(o) }
  #   # return objs
  #   # self.find(:all, :joins => "LEFT JOIN `locks` ON `#{self.to_s.underscore}`.`id` = `locks`.`with_id`", )
  # end
end