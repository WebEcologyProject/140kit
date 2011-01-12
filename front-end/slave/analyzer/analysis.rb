class Analysis
  
  require "#{ROOT_FOLDER}cluster-code/analyzer/analysis_flow"
  
  `ls #{ROOT_FOLDER}cluster-code/analyzer/tools/`.split.each {|f| require "#{ROOT_FOLDER}cluster-code/analyzer/tools/#{f}"}
  `ls #{ROOT_FOLDER}cluster-code/analyzer/library_functions/`.split.each {|f| require "#{ROOT_FOLDER}cluster-code/analyzer/library_functions/#{f}"}
  
  def self.tools
    return `ls #{ROOT_FOLDER}cluster-code/analyzer/tools/`.split.collect {|t| t.gsub(".rb", "")}.reject {|t| t.include?("|")}
  end
  
  def self.mean(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float, Date, Time, DateTime], class_name, attribute)
    if "datetime".include?(self.data_type(class_name, attribute))
      query = "select #{attribute} from #{class_name.to_s.underscore}"
      query += self.where(parameters)
      query += ";"
      result = Environment.db.query(query)
      results = []
      1.upto(result.num_rows) {|i| results << SQLParser.type_attributes(result.fetch_hash, result).to_a.flatten[1].to_f}
      return nil if results.length == 0
      mean = results.sum / results.length
      return Time.at(mean)
    else
      query = "select avg(#{attribute}) from #{class_name.to_s.underscore}"
      query += self.where(parameters)
      query += ";"
      result = Environment.db.query(query)
      return SQLParser.type_attributes(result.fetch_hash, result).to_a.flatten[1]
    end
  end
  
  def self.frequency_hash(class_name, attribute, parameters={})
    query = "select count(*) as frequency, #{attribute} from #{class_name.to_s.underscore}"
    if parameters.class == Hash && !parameters.empty?
      query += self.where(parameters)
    elsif parameters.class == String
      query += parameters
    end
    query += " group by #{attribute} order by count(*) desc;"
    # if block_given? 
    # This was having errors, may need to consult real programmers to deal with failed block_given? answers?
    # For now, frequency_hash requires block. - Devin
    objects = Database.spooled_result(query)
    yield objects
    # else
    #   result = Environment.db.query(query)
    #   hash = {}
    #   1.upto(result.num_rows) do |iii|
    #     row = SQLParser.type_attributes(result.fetch_hash, result).to_a.flatten
    #     hash[row[row.index(attribute)+1]] = row[row.index("frequency")+1]
    #   end
    #   return hash
    # end
  end
  
  def self.mode(class_name, attribute, parameters={})
    histogram = self.frequency_hash(class_name, attribute, parameters)
    histogram = histogram.sort {|a,b| b[1] <=> a[1]}
    results = histogram.select {|r| r[1] == histogram[0][1]}
    hash = {}
    results.each {|r| hash[r[0]] = r[1]}
    return hash
  end
  
  def self.median(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float, Date, Time, DateTime], class_name, attribute)
    query = "select #{attribute} from #{class_name.to_s.underscore}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    results = []
    1.upto(result.num_rows) {|i| results << SQLParser.type_attributes(result.fetch_hash, result).to_a.flatten[1]}
    return nil if results.length == 0
    return results[0] if results.length == 1
    results.sort!
    if "datetime".include?(results[0].class.to_s.downcase)
      return results.length.odd? ? results[results.length/2] : Time.at((results[results.length/2].to_f + results[results.length/2-1].to_f) / 2.0)
    else
      return results.length.odd? ? results[results.length/2] : (results[results.length/2].to_f + results[results.length/2-1].to_f) / 2.0
    end
  end
  
  def self.std_dev(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float], class_name, attribute)
    query = "select std(#{attribute}) from #{class_name.to_s.underscore}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    hash = result.fetch_hash
    return hash.empty? ? nil : SQLParser.type_attributes(hash, result).to_a.flatten[1]
  end
  
  def self.variance(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float], class_name, attribute)
    query = "select variance(#{attribute}) from #{class_name.to_s.underscore}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    hash = result.fetch_hash
    return hash.empty? ? nil : SQLParser.type_attributes(hash, result).to_a.flatten[1]
  end
  
  def self.max(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float, Date, Time, DateTime], class_name, attribute)
    query = "select max(#{attribute}) from #{class_name.to_s.underscore}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    hash = result.fetch_hash
    return hash.empty? ? nil : SQLParser.type_attributes(hash, result).to_a.flatten[1]
  end
  
  def self.min(class_name, attribute, parameters={})
    return nil if !self.valid_type?([Fixnum, Integer, Float, Date, Time, DateTime], class_name, attribute)
    query = "select min(#{attribute}) from #{class_name.to_s.underscore}"
    query += self.where(parameters)
    query += ";"
    result = Environment.db.query(query)
    hash = result.fetch_hash
    return hash.empty? ? nil : SQLParser.type_attributes(hash, result).to_a.flatten[1]
  end
  
  def self.where(parameters)
    query = " where"
    if !parameters.empty?
      parameters.each_pair {|k,v|
        if k.class == Array && k.length > 1
          if v.class == Array && v.length > 1
            k.each do |key|
              query += " and ("
              v.each do |val|
                query += " #{key} = #{SQLParser.prep_attribute(val)} or "
              end
              query.chop!.chop!.chop!.chop!
              query += ")"
            end
          else
            query = " and ("
            k.each do |key|
              query += " #{key} = #{SQLParser.prep_attribute(v)} or "
            end
            query.chop!.chop!.chop!.chop!
            query += ")"
          end
        else
          if v.class == Array && v.length > 1
            query += " and ("
            v.each do |val|
              query += " #{k} = #{SQLParser.prep_attribute(val)} or "
            end
            query.chop!.chop!.chop!.chop!
            query += ")"
          else
            query += " and #{k} = #{SQLParser.prep_attribute(v)} "
          end
        end
      }
    end
    query_clean = query.scan(/^\ *(where) \w* (.*)/)
    query = " "+query_clean[0][0]+" "+query_clean[0][1]
    return query
  end
  
  def self.valid_type?(valid_types, class_name, attribute)
    type = self.data_type(class_name, attribute)
    valid_types.collect! {|t| t.to_s.downcase}
    return valid_types.include?(type) ? true : false
  end
  
  def self.data_type(class_name, attribute)
    result = Environment.db.query("select #{attribute} from #{class_name.to_s.underscore} limit 1")
    hash = result.fetch_hash
    return nil if hash.nil?
    return SQLParser.type_attributes(hash, result).to_a.flatten[1].class.to_s.downcase
  end
  
  def self.conditional(curation)
    sql = " where ("
    for dataset in curation.datasets
      sql += " dataset_id = #{dataset.id} or "
    end
    sql = sql.chop.chop.chop.chop + ")"
    return sql
  end
  
  #deprecated
  # def self.conditional(collection)
  #   conditional = ""
  #   if collection.single_dataset
  #     m_ids = [collection.metadata.id]
  #     metadatas = [collection.metadata]
  #     conditional = " metadata_id = #{metadatas.first.id} and metadata_type = '#{metadatas.first.class.underscore.chop}' "
  #   else
  #     metadatas = [collection.metadatas]
  #     rm_ids = collection.metadatas.collect{|rm| rm.id if rm.class == RestMetadata}.compact
  #     sm_ids = collection.metadatas.collect{|sm| sm.id if sm.class == StreamMetadata}.compact
  #     rm_conditional = rm_ids.empty? ? "" : " (metadata_type = 'rest_metadata' and ( metadata_id = '#{rm_ids.join("' or metadata_id = '")}')) "
  #     sm_conditional = sm_ids.empty? ? "" : " (metadata_type = 'stream_metadata' and ( metadata_id = '#{sm_ids.join("' or metadata_id = '")}')) "
  #     if rm_ids.empty?
  #       conditional = sm_conditional
  #     elsif sm_ids.empty?
  #       conditional = rm_conditional
  #     elsif !rm_ids.empty? && !sm_ids.empty?
  #       conditional = rm_conditional+" or "+sm_conditional
  #     end
  #   end
  #   return " where "+conditional
  # end
  
  def self.time_conditional(time_variable, datetime, granularity)
    case granularity
    when "hour"
      return "#{time_variable} >= cast('#{datetime}:00:00' as datetime) and #{time_variable} <= cast('#{datetime}:59:59' as datetime)"
    when "date"
      return "#{time_variable} >= cast('#{datetime} 00:00:00' as datetime) and #{time_variable} <= cast('#{datetime} 23:59:59' as datetime)"
    when "month"
      month = datetime.split("-").last.to_i
      year = datetime.split("-").first.to_i
      return "#{time_variable} >= cast('#{datetime}-01 00:00:00' as datetime) and #{time_variable} <= cast('#{datetime}-#{U.month_days(month, year)} 23:59:59' as datetime)"
    when "year"
      return "#{time_variable} >= cast('#{datetime}-01-01 00:00:00' as datetime) and #{time_variable} <= cast('#{datetime}-12-31 23:59:59' as datetime)"
    end
  end
  
  #deprecated
  # def self.remove_broken_collections(collection)
  #   if collection.scraped_collection
  #     if collection.scrape.tweets.length == 0 && collection.scrape.users.length == 0
  #       AnalysisMetadata.find_all({:collection_id => collection.id}).each {|x| x.destroy}
  #       collection.metadatas.collect{|x| x.destroy}
  #       collection.scrape.destroy
  #       collection.destroy
  #     end  
  #   else
  #     if collection.metadatas.collect{|m| m.tweets_count}.sum == 0 && collection.metadatas.collect{|m| m.tweets_count}.sum == 0
  #       AnalysisMetadata.find_all({:collection_id => collection.id}).each {|x| x.destroy}
  #       collection.destroy
  #     end
  #   end
  # end
  
  def self.hashes_to_csv(hash_array, file_name, path=$w.tmp_path)
    require 'fastercsv'
    raise "Temp Folder not declared" if $w.tmp_path.nil?
    FasterCSV.open(path+file_name, "w") do |csv|
      keys = hash_array.first.keys
      csv << keys
      hash_array.each do |row|
        csv << keys.collect{|key| row[key]}
      end
    end
  end
  
  def self.proper_access_level(researcher_level, analysis_level)
    access_levels = ["User", "Private Researcher", "Commercial Account", "Admin"]
    return access_levels.index(researcher_level) >= access_levels.index(analysis_level)
  end
end