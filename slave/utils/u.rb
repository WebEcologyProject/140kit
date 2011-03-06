module U

  def self.append_and_save(objects, dataset)
    # U.append_dataset_id(objects, dataset)
    # 10.times do |i| 
    #   books << Book.new(:name => "book #{i}")
    # end
    Tweet.import objects[:tweets].collect {|t| Tweet.new(t.merge({:dataset => dataset.id})) }
    User.import objects[:users].collect {|u| User.new(u.merge({:dataset => dataset.id})) }
    # Database.save_all(objects)
    # puts objects.inspect
    puts
  end
  
  def self.append_dataset_id(objects, dataset)
    objects.values.flatten.compact.each do |object|
      object["dataset_id"] = dataset.id
    end
  end
  
  #deprecated
  # def self.append_scrape_id(objects, metadata)
  #   objects.values.flatten.compact.each do |object|
  #     object["metadata_id"] = metadata.id
  #     object["metadata_type"] = metadata.class.to_s.underscore.chop
  #     object["scrape_id"] = metadata.scrape_id
  #   end
  # end
    
  # def self.times_up(start_time, counter)
  #   if Time.now.to_f >= start_time.to_f+counter
  #     return true
  #   else return false
  #   end
  # end
  
  def self.times_up?(time)
    return DateTime.now.gmt >= time ? true : false
  end
  
  def self.uniform_columns(objects)
    total_attributes = objects.compact.collect {|object| object.keys}.flatten.uniq
    objects.compact.each do |object|
      total_attributes.each do |attribute|
        if object[attribute].nil?
          object[attribute] = ""
        end
      end
    end
    return objects
  end
  
  def self.return_data(url, rate_limiting_request=true)
    puts "Grabbing data from url: #{url}"
    tries = 0
    rate_limit_data = nil
    if rate_limiting_request
      while rate_limit_data.class != Hash
        begin
          rate_limit_data = JSON.parse(open(API_RATE_LIMIT_URL).read)
        rescue => e
          rate_limit_data = nil
          puts "CAN YOU SHOW ME A \"HAT WOBBLE\": #{e}"
          retry
        end
      end
      ttl = (rate_limit_data["reset_time_in_seconds"]-Time.now.to_i)
      hits_left = rate_limit_data["remaining_hits"]
      puts "#{hits_left} hits remaining; #{ttl} seconds remaining; sleeping for #{ttl/(hits_left+1).to_f} seconds."
      sleep((ttl/(hits_left+1).to_f).abs)
    end
    begin
      raw_data = open(url).read
    rescue Timeout::Error => e
      puts e
      if tries <= 3
        puts "This is my last attempt." if tries == 3
        puts "Retrying..."
        tries += 1
        retry
      end
      raw_data = "" if tries == 3
      puts "We couldn't grab the data: here's the data recieved:\n\n URL WAS: #{url}\n\n DATA WAS:\n\n#{raw_data}\n\n\n"  if tries == 3
      return raw_data
    rescue => e
      puts e
      if !e.to_s.include?("403")
        if tries <= 3
          puts "This is my last attempt." if tries == 3
          puts "Retrying..."
          tries += 1
          retry
        end
        raw_data = "" if tries == 3
        puts "We couldn't grab the data: here's the data recieved:\n\n URL WAS: #{url}\n\n DATA WAS:\n\n#{raw_data}\n\n\n"  if tries == 3
      end
      return raw_data
    end
    return raw_data
  end  
  
  def self.get_config
    return YAML.load_file("#{ROOT_FOLDER}/config/config.yml")
  end

  def hashes_to_csv()
    file = File.new(path, "w+")
    iterator = 0
    keys = hash_array.first.keys
    csv = keys.collect{|key| key+","}.to_s.chop+"\n"
    csv = csv+hash_array.map {
      |row| keys.collect {
        |key| 
          row[key].nil? ? '"",' : '"'+row[key].to_s.gsub('"', '""')+'",'
        }.to_s.chop+"\n"
      }.to_s
    file.write(csv)
    file.close
  end
  
  def self.month_days(month, year=nil)
    case month.to_i
    when 1
      return 31
    when 2
      if year%400 == 0
        return 28
      elsif year%100 == 0
        return 29
      elsif year%4 == 0
        return 28
      else return 29
      end
    when 3
      return 31
    when 4
      return 30
    when 5
      return 31
    when 6
      return 30
    when 7
      return 31
    when 8
      return 31
    when 9
      return 30
    when 10
      return 31
    when 11
      return 30
    when 12
      return 31
    end                                                                 
  end
end