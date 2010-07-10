class Database

  require "#{ROOT_FOLDER}cluster-code/site_data"
  require "#{ROOT_FOLDER}cluster-code/utils/sql_parser"
  
###DATA REQUEST METHODS###

  def self.find(parameters)
    Database.get(parameters, true)
  end
  
  def self.find_all(parameters)
    Database.get(parameters, !parameters[:limit].nil?)
  end

  def self.all
    query = "select * from #{self.to_s.underscore};"
    return Database.result(query)
  end

  def self.find_first(class_name)
    query = "select * from #{class_name} limit 1;"
    return Database.result(query)
  end

  def self.find_last(class_name)
    query = "select * from #{class_name} order by id desc limit 1;"
    return Database.result(query)
  end

###DATA MANIPULATION METHODS###

  def self.destroy_all(parameters)
    if !parameters[:id].nil? && !parameters[:id].empty?
      connection = Environment.db
      query = "delete from #{parameters[:class]} where id = #{parameters[:id].join(" or id = ")}"
      Database.run_query(connection, query)
      return true
    end
  end

  def self.destroy(parameters)
    if parameters[:id].nil?
      raise "Can't Destroy without ID"
    else
      query = "delete from #{parameters[:class]} where id=#{parameters[:id]}"
      puts query
      connection = Environment.db
      results = []
      query_result = Database.run_query(connection, query)
      return nil
    end    
  end

  def self.save(objects)
    if !objects.first.nil? && objects[objects.keys.first].first["id"].nil?
      Database.save_all(objects)
    else
      Database.update_all(objects)
    end
  end
  
  def self.save_all(objects)
    if !objects.empty?
      objects.each_pair do |k,v|
        if !v.compact.empty?
          objects_uploaded = 0
          object_groups = []
          while objects_uploaded < v.length
            object_groups << v[objects_uploaded..objects_uploaded+MAX_ROW_COUNT_PER_BATCH]
            objects_uploaded = objects_uploaded+MAX_ROW_COUNT_PER_BATCH > v.length ? v.length : objects_uploaded+MAX_ROW_COUNT_PER_BATCH
          end
          object_groups.collect{|partitioned_objects| self.batch_operation({k => partitioned_objects}, "insert ignore into")}
          end
        end
      end
    end
  
  def self.update(object, hash)
    self.write_db(SQLParser.update(object, hash))
  end
  
  def self.update(object, hash)
    self.write_db(SQLParser.update(object, hash))
  end
  
  def self.update_all(objects)
    if !objects.empty?
      objects.each_pair do |k,v|
        if !v.compact.empty?
          objects_uploaded = 0
          object_groups = []
          while objects_uploaded < v.length
            object_groups << v[objects_uploaded..objects_uploaded+MAX_ROW_COUNT_PER_BATCH]
            objects_uploaded = objects_uploaded+MAX_ROW_COUNT_PER_BATCH > v.length ? v.length : objects_uploaded+MAX_ROW_COUNT_PER_BATCH
          end
          object_groups.collect{|partitioned_objects| self.batch_operation({k => partitioned_objects}, "replace into")}
        end
      end
    end
  end
  
  def self.update_attributes(object_class, objects, attribute_set)
    replaced = {object_class => []}
    objects.each do |object|
      obj_attrs = object.attributes
      obj_attrs.each_pair do |obj_attr, value|
        if !attribute_set[obj_attr].nil?
          obj_attrs[obj_attr] = attribute_set[obj_attr]
        end
      end
      replaced[object_class] << obj_attrs
    end
    self.update_all(replaced)
  end
  
  def self.update_attributes(object_class, objects, attribute_set)
    replaced = {object_class => []}
    objects.each do |object|
      ## check for nil objects here?
      obj_attrs = object.attributes
      obj_attrs.each_pair do |obj_attr, value|
        if !attribute_set[obj_attr].nil?
          obj_attrs[obj_attr] = attribute_set[obj_attr]
        end
      end
      replaced[object_class] << obj_attrs
    end
    self.update_all(replaced)
  end

###DATA PREP METHODS###

###DATA PREP METHODS###

  def self.get(parameters, limit_specific)
    parameters[:data].delete(:load) if parameters[:data].class == Hash
    if !parameters[:class].nil?
      prefix = "select * from #{parameters[:class]}"
      conditional = " where"
      if !parameters[:data].empty?
        if parameters[:data].class == String
          query = prefix+conditional+" "+parameters[:data]
          return Database.result(query)
        else
          parameters[:data].each_pair {|k,v|
            if k.class == Array && k.length > 1
              if v.class == Array && v.length > 1
                k.each do |key|
                  conditional += " and ("
                  v.each do |val|
                    conditional += " #{key} = '#{SQLParser.prep_attribute(val)}' or "
                  end
                  conditional.chop!.chop!.chop!.chop!
                  conditional += ")"
                end
              else
                conditional = " and ("
                k.each do |key|
                  conditional += " #{key} = '#{SQLParser.prep_attribute(v)}' or "
                end
                conditional.chop!.chop!.chop!.chop!
                conditional += ")"
              end
            else
              if v.class == Array && v.length > 1
                conditional += " and ("
                v.each do |val|
                  conditional += " #{k} = '#{SQLParser.prep_attribute(val)}' or "
                end
                conditional.chop!.chop!.chop!.chop!
                conditional += ")"
              else
                conditional += " and #{k} = '#{SQLParser.prep_attribute(v)}' "
              end
            end
          }
        end
      end
      conditional = conditional.scan(/^\ *(where) \w* (.*)/)
      suffix = ""
      order = parameters.delete(:order)
      suffix += order.nil? ? "" : " order by #{order}"
      if limit_specific
        limit = parameters.delete(:limit)
        suffix += limit.nil?  ? " limit 1" : " limit #{limit}"
      end
      suffix += ";"
      query = prefix + " " + conditional.flatten.join(" ") + suffix
      return Database.result(query)
    else
      raise "Must Specify A Class to write to!"
      return false
    end
  end  

  def self.result(query)
    puts query
    connection = Environment.db
    results = []
    query_result = Database.run_query(connection, query)
    while row = query_result.fetch_hash do
      results << SQLParser.type_attributes(row, query_result)
    end
    return results
  end
    
  def self.submit(query)
    puts query
    connection = Environment.db
    results = []
    query_result = Database.run_query(connection, query)
    return nil
  end  
  
  def self.run_query(connection, query)
    query_result = false
    retry_step = false
    error = ""
    t = Time.now.to_i
    while query_result == false && Time.now.to_i-t <= TIMEOUT_MAX
      begin
        if retry_step
          puts "Retrying query; failed with exception: #{e}"
        end
        query_result = connection.query(query)
      rescue => e
        error = e.to_s
        retry_step = true
        retry
      end
    end
    if query_result == false
      return nil
    else
      return query_result
    end
  end
  
  def self.batch_operation(objects, declarative_statement)
    objects.each_pair do |class_name, data_set|
      #########################################################
      #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - #
      #                                                       #
      # "Someday, there will be something here that looks at  #
      # our max_allowed_packet_size, then breaks up the batch #
      # calls to 80% of the byte size stipulated so that      #
      # we're right on the threshold of awesome. That day     #
      # is not today."  - Devin Gaffney, Apr 14th, 2010       #
      #                                                       #
      # - - - - - - - - - - - - - - - - - - - - - - - - - - - #
      #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
      #########################################################
      self.write_db(SQLParser.batch(class_name, data_set, declarative_statement))      
    end
  end
  
  def self.write_db(sql_statement)
    if !sql_statement.nil? && sql_statement != false
      connection = Environment.db
      puts sql_statement
      query_result = Database.run_query(connection, sql_statement)
      puts query_result
      return query_result
    else 
      Failure.new({:message => "Failure to save objects with given SQL query, Database.write_db", :trace => "SQL Statement value: #{sql_statement} SQL Statement class: #{sql_statement.class}", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
      return "Error in SQL Query"
    end
  end
  
###DATA MANAGEMENT METHODS###

  def self.flush
    connection = Environment.db
    for table in Database.tables
      query_result = Database.run_query(connection, "TRUNCATE TABLE `#{table}`;")
    end
    p = Prioritizer.new({:locked => false, :instance_id => ""})
    p.save
  end
  
  def self.tables
    connection = Environment.db
    tables = []
      result = Database.run_query(connection, "show tables;")
    result.each do |r|
      tables << r[0]
    end
    return tables
  end
  
  ## maybe this doesn't belong here, it's more of a monitoring utility than a database function.
  def self.monitor(table, update_interval)
    db = Environment.db
    prev_count = 0
    sum_new_rows = 0
    first = true
    start = Time.ntp.to_f
    loop do
      r = db.query("select count(id) from #{table}")
      count = r.fetch_row[0].to_i
      prev_count = count if first
      first = false
      new_rows = count - prev_count
      sum_new_rows += new_rows
      avg_new_rows_per_sec = sum_new_rows.to_f / (Time.ntp.to_f - start)
      dur_sec = Time.ntp.to_i - start.to_i
      dur = []
      dur << "#{dur_sec / 60 / 60}"
      dur << "#{dur_sec / 60 % 60}"
      dur << "#{dur_sec % 60}"
      dur.map {|x| x.insert(0, "0") if x.length == 1}
      puts ""
      puts "============================="
      puts "#{table} count: #{count}"
      puts "new #{table}: #{new_rows}"
      puts "avg new #{table} p/s: #{avg_new_rows_per_sec}"
      puts "monitor duration: #{dur[0]}:#{dur[1]}:#{dur[2]}"
      puts "============================="
      prev_count = count
      sleep update_interval
    end
  end
end
