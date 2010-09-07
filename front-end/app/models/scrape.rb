class Scrape < ActiveRecord::Base
  belongs_to :researcher
  has_many :tweets
  has_many :users
  has_many :stream_metadatas
  belongs_to :collection, :foreign_key => 'primary_collection_id'
  before_save :derive_length
  before_update :update_name
  after_create :fill_out_secondary_data
  
  def validate_on_create
    if self.scrape_type == "Search"
      if self.name == ""
        errors.add("name", "it looks like you forgot to put in an actual search term. Perhaps you should try \"Bieber\"?")
      end
      other_current_scrapes = self.researcher.collections.select{|c| !c.single_dataset && (!c.finished && !c.analyzed)}.select{|c| !c.mothballed}.collect{|c| c.name}
      if other_current_scrapes.include?(self.name)
        errors.add("name: " "You already have another scrape for that term currently running in our system. Sorry, we only allow one scrape per term per person at any time.")
      end
      if (self.run_ends.to_i - Time.now.to_i) < 2.minutes.to_i
        errors.add("run_ends", "This scrape isn't long enough. Scrapes must be longer than 2 minutes.")
      elsif (self.run_ends.to_i - Time.now.to_i) > 7.days.to_i
        errors.add("run_ends", "This scrape is too long. Scrapes must be shorter than one week.")
      end
      if self.name.scan(/\w/).flatten.empty?
        errors.add("name", "Your scrape must contain at least one letter or number.")
      end
    elsif self.scrape_type == "user_source_scrape"
      if self.name.empty?
        errors.add("name", "it looks like you forgot to put in an actual search term. Perhaps you should try \"AplusK,BPOilSpill,ShitMyDadSays\"?")
      end
    end
  end
  
  def self.create_rest_temp_file(params)
    researcher = Researcher.find(params[:scrape][:researcher_id])
    if !`ls public/files/source_data`.split("\n").include?(researcher.user_name)
      `mkdir public/files/source_data/#{researcher.user_name}`
      if !`ls public/files/source_data/#{researcher.user_name}`.split("\n").include?(params[:scrape][:scrape_type])
        `mkdir public/files/source_data/#{researcher.user_name}/#{params[:scrape][:scrape_type]}`
      end
    end
    folder_name = Digest::SHA1.hexdigest(Time.now.to_s+rand(100000).to_s)
    `mkdir public/files/source_data/#{researcher.user_name}/#{params[:scrape][:scrape_type]}/#{folder_name}`
    if params[:scrape][:uploaded_data].class == Tempfile
      f = File.open("public/files/source_data/#{researcher.user_name}/#{params[:scrape][:scrape_type]}/#{folder_name}/source_data.txt", "w+")
      
      temp_data = params[:scrape][:uploaded_data].read.split(/[,\n\t]/).flatten.select{|a| !a.empty?}.flatten.collect{|a| a.gsub(/\W/, "")}.join(",")
      if self.valid(temp_data)
        f.write(temp_data)
        f.close
      end
    elsif params[:scrape][:uploaded_data].class == String
      f = File.open("public/files/source_data/#{researcher.user_name}/#{params[:scrape][:scrape_type].downcase.gsub(" ", "_")}/#{folder_name}/source_data.txt", "w+")
      temp_data = params[:scrape][:uploaded_data]
      if self.valid(temp_data)
        f.write(temp_data)
        f.close
      end
    elsif params[:scrape][:uploaded_data].class == NilClass
      errors.add("Source Data: " " Source Data not found")
    else
      errors.add("Source Data: " " Your data was of a bad type: #{params[:scrape][:uploaded_data]}")
    end
    params[:scrape].delete(:uploaded_data)
    params[:scrape][:ref_data] = "/files/source_data/#{researcher.user_name}/#{params[:scrape][:scrape_type].downcase.gsub(" ", "_")}/#{folder_name}/source_data.txt"
    return params
  end
  
  def fill_out_secondary_data
    if self.scrape_type == "Search"
      scrape_method = "Stream"
      @stream_metadata = StreamMetadata.new
      @stream_metadata.term = self.name
      @stream_metadata.sanitized_term = self.name.downcase.gsub("@", "").gsub("#", "").gsub(".", "")
      @stream_metadata.scrape = self
      @stream_metadata.researcher_id = self.researcher.id
      @stream_metadata.created_at = Time.now
      @stream_metadata.save
      @stream_collection = Collection.new
      @stream_collection.name = "Dataset_Stream_#{@stream_metadata.id}"
      @stream_collection.folder_name = "Dataset_Stream_#{@stream_metadata.id}-#{Time.now.strftime("%Y-%m-%d__%H:%M:%S")}"
      @stream_collection.scrape = self
      @stream_collection.researcher = self.researcher
      @stream_collection.single_dataset = true
      @stream_collection.stream_metadata = @stream_metadata
      @stream_collection.scraped_collection = true
      @stream_collection.created_at = Time.now
      @stream_collection.updated_at = Time.now
      @stream_collection.scrape_method = scrape_method
      @stream_collection.save
    elsif self.scrape_type = "User Source Scrape"
      scrape_method = "REST"
      @rest_metadata = RestMetadata.new
      @rest_metadata.scrape = self
      @rest_metadata.created_at = Time.now
      @rest_metadata.updated_at = Time.now
      @rest_metadata.researcher = self.researcher
      @rest_metadata.source_data = self.ref_data
      @rest_metadata.save
      @rest_collection = Collection.new
      @rest_collection.name = "Dataset_REST_#{@rest_metadata.id}"
      @rest_collection.folder_name = "Dataset_REST_#{@rest_metadata.id}-#{Time.now.strftime("%Y-%m-%d__%H:%M:%S")}"
      @rest_collection.scrape_id = self.id
      @rest_collection.researcher = self.researcher
      @rest_collection.single_dataset = true
      @rest_collection.rest_metadata = @rest_metadata
      @rest_collection.scraped_collection = true
      @rest_collection.created_at = Time.now
      @rest_collection.updated_at = Time.now
      @rest_collection.scrape_method = scrape_method
      @rest_collection.save
      @rest_collection.save
    end
    @collection = Collection.new
    @collection.name = self.name
    @collection.researcher = self.researcher
    @collection.scrape_id = self.id
    @collection.scraped_collection = true
    @collection.created_at = Time.now
    @collection.updated_at = Time.now
    @collection.scrape_method = scrape_method
    @collection.save
    self.collection = @collection
    self.save
    if self.scrape_type == "Search"
      @stream_metadata.collection_id = @stream_collection.id
      @stream_metadata.save
      @collection.stream_metadatas << @stream_metadata
    elsif self.scrape_type == "User Source Scrape"
      @rest_metadata.collection_id = @rest_collection.id
      @rest_metadata.save
      @collection.rest_metadatas << @rest_metadata
    end
  end
  
  def derive_length
    #PATCH
    self.branching = false if self.scrape_type == "User Source Scrape"
    self.length = run_ends.to_i-Time.now.to_i
    self.last_branch_check = Time.now
    self.folder_name = "#{self.name.downcase.gsub(".", "").gsub(" ", "_").gsub(/\W/, "")}-#{Time.now.strftime("%Y-%m-%d__%H:%M:%S")}"
    self.generate_humanized_length
  end
  
  def generate_humanized_length
    length = self.length
    self.humanized_length = ""
    weeks = length/604800
    if weeks > 0
      length -= weeks*604800
      self.humanized_length += weeks == 1 ? "#{weeks} week, " : "#{weeks} weeks, "
    end
    days = length/86400
    if days > 0
      length -= days*86400
      self.humanized_length += days == 1 ? "#{days} day, " : "#{days} days, "
    end
    hours = length/3600
    if hours > 0
      length -= hours*3600
      self.humanized_length += hours == 1 ? "#{hours} hour, " : "#{hours} hours, "
    end
    minutes = length/60
    if minutes > 0
      length -= minutes*60
      self.humanized_length += minutes == 1 ? "#{minutes} minute, " : "#{minutes} minutes, "
    end
    seconds = length
    if seconds > 0 
      length -= minutes*60
      self.humanized_length += seconds == 1 ? "#{seconds} second, " : "#{seconds} seconds, "      
    end
    self.humanized_length.chop!.chop! if !self.humanized_length.empty? && !self.humanized_length.nil?
  end
  
  def update_name
    self.collection.name = self.name
  end
  
  def self.valid(temp_data)
    require 'open-uri'
    if temp_data.split(/[,\t\n]/).length > 1
      return true
    else
      begin
        result = JSON.parse(open("http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{temp_data.split(/[,\t\n]/)}&count=1").read)
      rescue OpenURI::HTTPError
        return false
      end
      return result.first["user"]["screen_name"].downcase == temp_data.split(",").first
    end
  end
end