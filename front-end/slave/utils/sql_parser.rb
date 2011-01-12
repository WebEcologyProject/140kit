class SQLParser < Database
  
  def self.update(object, hash)
    sql_values_statement = ""
    hash.each_pair {|k, v| sql_values_statement << "#{k}=#{v},"}
    sql_values_statement = sql_values_statement.chop
    return "update `#{object.class.to_s.downcase.pluralize}` \n set #{sql_values_statement} \n where id=#{object.id}"
  end
  
  def self.batch(class_name, data_set, declarative_statement)
    sql_declarative_statement = ""
    sql_values_statement = ""
    sql_declarative_statement = "#{declarative_statement} `#{class_name.to_s}` ("
    if data_set.nil? || data_set.empty?
      puts "======================================\n"*5
      puts "\n\n"
      puts "class_name: #{class_name.inspect}"
      puts "\n\n"
      puts "data_set: #{data_set.inspect}"
      puts "\n\n"
      puts "WE ARE PROBABLY BEING RATE LIMITED!"
      puts "\n\n"
      puts "======================================\n"*5
      return false
    else
      if !data_set.first.nil?
        key_list = data_set.first.keys
        key_list.each do |k|
          if k != data_set.first.keys.last
            sql_declarative_statement << "`#{k}`, "
          else
            sql_declarative_statement << "`#{k}`) values\n"
          end
        end
        data_set.compact.each do |object|
          first_value = true
          key_list.each do |key|
            clean_attribute = SQLParser.prep_attribute(object[key])
            if first_value
              if key_list.length > 1
                sql_values_statement << "(#{clean_attribute}, "
              else
                sql_values_statement << "(#{clean_attribute}),\n"
              end
            elsif key == key_list.last
              sql_values_statement << "#{clean_attribute}),\n"
            else
              sql_values_statement << "#{clean_attribute}, "
            end
            first_value = false
          end
        end
      end
      return sql_declarative_statement+sql_values_statement.chop.chop+";"
    end
  end

  def self.type_attributes(row, query_result)
    map_hash = {}
    final_row = {}
    type_map = query_result.fetch_fields.collect{|field| map_hash[field.name] = field.type}
    row.each_pair do |k,v|
      if map_hash[k] == 1
        final_row[k] = v.nil? ? nil : v.to_bool
      elsif map_hash[k] == 3 || map_hash[k] == 8
        final_row[k] = v.nil? ? nil : v.to_i
      elsif map_hash[k] == 246 || map_hash[k] == 5
        final_row[k] = v.nil? ? nil : v.to_f
      elsif map_hash[k] == 12
        if !v.nil?
          time_attr = Time.at(0)
          begin
            if v == "0000-00-00 00:00:00"
              time_attr = nil
            else
              year,mon,day,hour,min,sec = v.scan(/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/).flatten
              time_attr = Time.gm(year,mon,day,hour,min,sec).localtime
            end
          rescue ArgumentError => e
            puts "Attempted to save weird time; #{e}, logging this issue and reporting to db."
            Failure.new({:message => "Bad Time Attribute when trying to add in time from a query result in SQL Parser.", :trace => " Error Type: ArgumentError. Trace: #{e}. Value: #{v}. Value Class: #{v.class}", :created_at => Time.ntp, :instance_id => $w.instance_id}).save
          end
          final_row[k] = time_attr
        else final_row[k] = nil
        end
      elsif map_hash[k] >= 252
        final_row[k] = v
      else
        raise "Unknown Type of variable! No rule set for byte length of #{map_hash[k]}"
      end
    end
    return final_row
  end
  
  def self.prep_attributes(parameters)
    new_parameters = {}
    parameters.each_pair do |k,v|
      new_parameters[k] = SQLParser.prep_attribute(v)
    end
    return new_parameters
  end
  
  def self.prep_attribute(attribute)
    if attribute.class == String
      attribute = "#{Mysql.escape_string(attribute)}"
    # elsif attribute.class == Fixnum || attribute.class == Integer || attribute.class == Float
    elsif attribute.class == Time
      attribute = "#{attribute.utc.strftime("%Y-%m-%d %H:%M:%S")}"
    elsif attribute.class == FalseClass
      attribute = "0"
    elsif attribute.class == TrueClass
      attribute = "1"
    elsif attribute.class == NilClass
      attribute = "NULL"
    end
    attribute = "'#{attribute}'" if attribute != "NULL"
    if attribute.class == String && ["''", "'\n'", "'\n    '"].include?(attribute.gsub(" ", ""))
      attribute = "NULL"
    end
    return attribute
  end
end
