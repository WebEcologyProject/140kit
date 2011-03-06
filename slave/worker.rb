require 'rubygems'

require 'dm-core'
require 'dm-aggregates'
require 'dm-validations'

require 'extensions/dm-extensions'
# require 'extensions/array'
require 'extensions/string'
# require 'extensions/hash'
# require 'extensions/time'
# require 'extensions/date'

require 'models/instance'
require 'models/lock'
require 'models/whitelisting'
require 'models/curation'
require 'models/dataset'
require 'models/tweet'
require 'models/user'
require 'models/analytical_offering'
require 'models/analysis_metadata'

require 'utils/u'
require 'json'

class Worker < Instance
  
  # attr_accessor :user_account, :username, :password, :start_time, :next_dataset_ends, :queue, :params, :datasets
  attr_accessor :curation
  
  @@words = File.open("analyzer/resources/words.txt", "r").read.split
  @@rest_analytics = ["retweet_graph"]
  
  def initialize
    super
    self.instance_type = "analyzer"
    # @datasets = []
    # @queue = []
    at_exit { do_at_exit }
  end
  
  def do_at_exit
    puts "Exiting."
    # save_queue
    # unlock(@user_account)
    # unlock_all(@datasets)
    destroy_locks
    self.destroy
  end
  
  def work
    puts "Working..."
    check_in
    puts "Entering work routine."
    loop do
      if !killed?
        work_routine
      else
        puts "Just nappin'."
        sleep(SLEEP_CONSTANT)
      end
    end
  end
  
  def work_routine
    @curation = select_curation
    if !@curation.nil?
      final_counts
      create_jobs
    end
    do_analysis_jobs
  end
  
  def select_curation
    curations = Curation.unlocked(:all, "analyzed=0").reject {|c| c.datasets.collect {|d| d.scrape_finished }.include?(false) }
    for curation in curations
      return curation if lock(curation)
    end
    return nil
  end
  
  def final_counts
    for dataset in @curation.datasets
      dataset.tweets_count = Tweet.count(:dataset_id => dataset.id) if dataset.tweets_count.nil?
      dataset.users_count = User.count(:dataset_id => dataset.id) if dataset.users_count.nil?
      dataset.save
    end
  end
  
  def create_jobs
    # if the num of finished metadatas == total metadatas and total > 0
    unfinished = AnalysisMetadata.count(:curation_id => @curation.id, :finished => false)
    if unfinished == 0
      total = AnalysisMetadata.count(:curation_id => @curation.id)
      if total > 0
        @curation.analyzed = true
        @curation.save
      else
        puts "Create jobs for dataset #{@curation.id}"
        spawn_analysis_metadatas
      end
    end
  end
  
  def spawn_analysis_metadatas
    analytical_offerings = AnalyticalOffering.all(:enabled => true)
    new_analysis_metadatas = []
    analytical_offerings.each do |analytic|
      #FIXME: no access level checking
      metadata = {  :function => analytic.function,
                    :save_path => analytic.save_path,
                    :curation_id => @curation.id,
                    :rest => analytic.rest }
      new_analysis_metadatas << metadata
    end
    AnalysisMetadata.save_all(new_analysis_metadatas)
  end
  
  def do_analysis_jobs
    # WARNING: TODO: rest_allowed not implemented yet
    while !AnalysisMetadata.unlocked.empty?
      metadata = AnalysisMetadata.unlocked(:first)
      if !metadata.nil? && lock(metadata)
        route(metadata)
        metadata.update(:finished => true)
      end
    end
    puts "No analysis work to do right now."
  end
  
  def route(metadata)
    puts "#{metadata.function}(#{metadata.curation_id}, \"#{metadata.save_path}\")"
    puts "\n\n\nI GOT METADATA #{metadata.id}!!! #{metadata.inspect}\n\n\n"
    sleep(3)
  end
  
  ###
    # 
    # def final_counts
    #   datasets = Dataset.unlocked(:all, "scrape_finished=0 AND tweets_count=NULL AND users_count=NULL")
    #   datasets = lock_all(datasets)
    #   for dataset in datasets
    #     puts "Final counts for dataset #{dataset.id}"
    #     dataset.tweets_count = Tweet.count(:dataset_id => dataset.id)
    #     dataset.users_count = User.count(:dataset_id => dataset.id)
    #     unlock(dataset)
    #   end
    # end
    # 
    # def create_jobs
    #   curations = Curation.unlocked(:all, "analyzed=0").reject {|c| c.datasets.collect {|d| d.scrape_finished }.include?(false) }
    #   puts "#{curations.length} curations to lock"
    #   curations = lock_all(curations)
    #   puts "#{curations.length} curations locked"
    #   for curation in curations
    #     # if the num of finished metadatas == total metadatas and total > 0
    #     unfinished = AnalysisMetadata.count(:curation_id => curation.id, :finished => false)
    #     if unfinished == 0
    #       total = AnalysisMetadata.count(:curation_id => curation.id)
    #       if total > 0
    #         curation.analyzed = true
    #         curation.save
    #       else
    #         puts "Create jobs for dataset #{curation.id}"
    #         spawn_analysis_metadatas(curation.id)
    #       end
    #     end
    #     unlock(curation)
    #   end
    # end
    # 
    # def do_analysis_jobs
    #   # WARNING: TODO: rest_allowed not implemented yet
    #   while !AnalysisMetadata.unlocked.empty?
    #     metadata = AnalysisMetadata.unlocked(:first)
    #     if !metadata.nil? && lock(metadata)
    #       route(metadata)
    #       metadata.finished = true
    #       metadata.save
    #     end
    #   end
    #   puts "No analysis work to do right now."
    # end
    # 
    # def route(metadata)
    #   puts "#{metadata.function}(#{metadata.curation_id}, \"#{metadata.save_path}\")"
    #   puts "\n\n\nI GOT METADATA #{metadata.id}!!! #{metadata.inspect}\n\n\n"
    #   sleep(10)
    # end
    # 
    # def spawn_analysis_metadatas(curation_id)
    #   analytical_offerings = AnalyticalOffering.all(:enabled => true)
    #   new_analysis_metadatas = []
    #   analytical_offerings.each do |analytic|
    #     #FIXME: no access level checking
    #     # if Analysis.proper_access_level(collection.researcher.role, ao.access_level)
    #       metadata = {}
    #       metadata["function"] = analytic.function
    #       metadata["save_path"] = analytic.save_path
    #       metadata["curation_id"] = curation_id
    #       metadata["rest"] = analytic.rest
    #       new_analysis_metadatas << metadata
    #     # end
    #   end
    #   AnalysisMetadata.save_all(new_analysis_metadatas)
    # end
    
    ##########
  
  # def self.redact_metadata(scrape, metadatas)
  #   for metadata in metadatas
  #     if Tweet.count({:metadata_id => metadata.id}) == 0
  #       analyses = AnalysisMetadata.find_all({:collection_id => metadata.collection.id})
  #       analyses.collect{|a| a.destroy}
  #       metadata.collection.destroy if !metadata.collection.nil?
  #       # This is done as a quick fix for now; you can't destroy without an id.
  #       # Since a habtm table does not have an id, it thus cannot be destroyed.
  #       Database.submit("delete from collections_stream_metadatas where collection_id = '#{scrape.collection.id}' and stream_metadata_id = '#{metadata.id}'")
  #       metadata.destroy
  #     end
  #   end
  # end
  # 
  # def self.tweet_user_count
  #   if U.times_up($w.last_count_check, COUNT_CHECK_INTERVAL)
  #     # update counts for collections that are currently being scraped
  #     scrapes = Scrape.find_all({:scrape_finished => false})
  #     for scrape in scrapes
  #       metadatas = scrape.metadatas.select{|m| (m.class == StreamMetadata && m.term != "retweet") || (m.class == RestMetadata)}
  #       metadatas.each do |metadata|
  #         metadata.tweets_count = Tweet.count({:metadata_id => metadata.id, :metadata_type => metadata.class.underscore.chop})
  #         metadata.users_count = User.count({:metadata_id => metadata.id, :metadata_type => metadata.class.underscore.chop})
  #         metadata.save #done singularly because we don't have a general save_object method.... (diff metadata_typs necessitate this)
  #       end
  #       tweets_count = metadatas.collect {|m| m.tweets_count}.sum
  #       users_count = metadatas.collect {|m| m.users_count}.sum
  #       collections = Collection.find_all({:scrape_id => scrape.id})
  #       collections.each do |collection|
  #         collection.tweets_count = collection.metadatas.collect{|m| m.tweets_count}.sum
  #         collection.users_count = collection.metadatas.collect{|m| m.users_count}.sum
  #       end
  #       Collection.update_all(collections)
  #     end
  #     # update counts for curated collections that have just been frozen
  #     ## HEY, DOES THIS WORK FOR REST TOO??
  #     ### Ian, that is clearly targeting curated collections...
  #     collections = Collection.find_all({:scraped_collection => false, :finished => true, :tweets_count => 0, :users_count => 0})
  #     for collection in collections
  #       metadatas = collection.metadatas.reject {|m| m.term == "retweet"}
  #       tweets_count = metadatas.collect {|m| m.tweets_count}.sum
  #       users_count = metadatas.collect {|m| m.users_count}.sum
  #       collection.tweets_count = tweets_count
  #       collection.users_count = users_count
  #       collection.save
  #     end
  #     Collection.update_all(collections)
  #     $w.last_count_check = Time.now
  #   end
  # end
  # 
  # def self.check_like_terms
  #   scrapes = Scrape.find_all({:scrape_finished => false, :branching => true})
  #   scrapes = scrapes.select {|s| U.times_up(s.last_branch_check, BRANCH_CHECK_INTERVAL)}
  #   for scrape in scrapes
  #     if scrape.class != NilClass && !scrape.flagged
  #       scrape.flagged = true
  #       scrape.instance_id = $w.instance_id
  #       scrape.save
  #       sleep(SLEEP_CONSTANT)
  #       scrape = Scrape.find({:instance_id => $w.instance_id, :id => scrape.id})
  #       if scrape.class != NilClass && scrape.instance_id == $w.instance_id
  #         tweets = []
  #         result = Environment.db.query("select text from tweets where scrape_id = #{scrape.id} limit 1000")
  #         1.upto(result.num_rows) {|i| tweets << result.fetch_row[0]}
  #         words = {}
  #         tweets = tweets.collect {|t| t.downcase}
  #         for tweet in tweets
  #           for word in tweet.gsub(/\W/, " ").split.uniq
  #             words[word] = words.has_key?(word) ? words[word] + 1 : 1
  #           end
  #         end
  #         threshold = tweets.length.to_f * LIKENESS_THRESHOLD
  #         new_terms = words.select {|k,v| v >= threshold}.collect {|t| t[0]}
  #         existing_terms = scrape.metadatas.collect {|m| m.term}
  #         new_terms = new_terms - existing_terms
  #         new_terms = new_terms - @@words
  #         for term in new_terms
  #           self.grow_branch(scrape, term)
  #         end
  #         if scrape.class != NilClass
  #           scrape.flagged = false
  #           scrape.instance_id = ""
  #           scrape.save
  #         end
  #       end
  #     end
  #   end
  # end
  # 
  # def self.check_trends
  #   scrapes = Scrape.find_all({:scrape_type => "trend", :scrape_finished => false})
  #   scrapes = scrapes.select {|s| U.times_up(s.last_branch_check, BRANCH_CHECK_INTERVAL) || s.last_branch_check.nil?}
  #   if !scrapes.empty?
  #     trending_terms = Environmental.trending_terms
  #     for scrape in scrapes
  #       if scrape.class != NilClass && !scrape.flagged
  #         scrape.flagged = true
  #         scrape.instance_id = $w.instance_id
  #         scrape.save
  #         sleep(SLEEP_CONSTANT)
  #         scrape = Scrape.find({:instance_id => $w.instance_id, :id => scrape.id})
  #         if scrape.class != NilClass && scrape.instance_id == $w.instance_id
  #           metadatas = scrape.metadatas
  #           metadatas = metadatas.reject {|m| m.finished}
  #           db_trends = {}
  #           metadatas.each {|m| db_trends["#{m.sanitized_term.downcase}"] = m.term}
  #       
  #           bad_terms = trending_terms.select {|t| t.include?(" ")}
  #           trending_terms = trending_terms - bad_terms
  #           split_terms = bad_terms.select {|t| t.include?(" OR ")}.collect {|t| t.split(" OR ")}.flatten.reject {|t| t.include?(" ")}.uniq
  #           trending_terms = trending_terms + split_terms
  #       
  #           twitter_trends = {}
  #           trending_terms.each {|t| twitter_trends["#{t.sanitize_for_streaming.downcase}"] = t}
  #       
  #           new_trends = twitter_trends
  #           db_trends.each_key {|t| new_trends.delete_if {|k,v| k == t}}
  #       
  #           old_trends = db_trends.keys - trending_terms.collect {|t| t.sanitize_for_streaming.downcase}
  #           metadatas_to_finish = metadatas.select {|m| old_trends.include?(m.sanitized_term.downcase)}
  #           metadatas_to_finish.each {|m| m.finished = true; m.save}
  #           new_trends.each_value {|t| self.grow_branch(scrape, t)}
  #           scrape.last_branch_check = Time.ntp
  #           scrape.save
  #         end
  #         if scrape.class != NilClass
  #           scrape.flagged = false
  #           scrape.instance_id = ""
  #           scrape.save
  #         end
  #       end
  #     end
  #   end
  # end
  # 
  # def self.do_analysis_work    
  #   metadata = Scheduler.decide_analysis_metadata
  #   if !metadata.nil?
  #     metadata.processing = true
  #     metadata.save
  #     self.route(metadata)
  #     metadata.finished = true
  #     metadata.save
  #   else puts "No analysis work to do."
  #   end
  # end
  # 
  # def self.route(metadata)
  #   # if Analysis.conditional(metadata.collection) != " where "
  #     puts "#{metadata.function}(#{metadata.curation_id}, \"#{metadata.save_path}\")"
  #     # eval("#{metadata.function}(#{metadata.curation_id}, \"#{metadata.save_path}\")")
  #     puts "\n\n\nI GOT METADATA #{metadata.id}!!!\n\n\n"
  #     sleep(10)
  #   # else
  #   #   Analysis.remove_broken_collections(metadata.collection)
  #   # end
  # end
  #   
  # def self.grow_branch(scrape, term)
  #   if scrape.branching
  #     branching = true
  #   else
  #     branching = false
  #   end
  #   sm = StreamMetadata.new({
  #     :scrape_id => scrape.id,
  #     :researcher_id => scrape.researcher.id,
  #     :term => term,
  #     :sanitized_term => term.sanitize_for_streaming,
  #     :created_at => Time.ntp,
  #     :updated_at => Time.ntp,
  #     :branching => branching
  #     })
  #   sm = sm.save
  #   collection = Collection.new({
  #     :researcher_id => scrape.researcher.id,
  #     :name => "Dataset_Stream_#{sm.id}",
  #     :folder_name => "Dataset_Stream_#{sm.id}_#{Time.ntp.strftime("%Y-%m-%d__%H:%M:%S")}_Scrape_#{scrape.id}_Term_#{term}",
  #     :updated_at => Time.ntp,
  #     :created_at => Time.ntp,
  #     :scrape_method => "Stream",
  #     :scrape_id => scrape.id,
  #     :scraped_collection => true,
  #     :single_dataset => true
  #   })
  #   collection = collection.save
  #   sm.collection_id = collection.id
  #   sm.save
  #   csm = CollectionsStreamMetadata.new({
  #     :collection_id => scrape.collection.id,
  #     :stream_metadata_id => sm.id
  #   }).save
  #   # AnalysisFlow.create_singular_analysis_metadatas(collection)
  # end
  # 
  # def self.generate_scrape_done_email(collection)
  #   if !collection.single_dataset
  #     subject = "Hey #{collection.researcher.user_name}, your data for the term #{collection.name} has been added to our system."
  #     message_content = "So, we thought you would want to know that your work has finished up.
  #     You can start to go through your data at this url: http://140kit.com/#{collection.researcher.user_name}/collections/#{collection.id}.\n
  #     (Note: If you requested any analytical work to be done on the data, you will recieve a separate notification of when that is finished. Hang tight. For now, you can look at it in basic views, or perhaps request a CSV.)
  #     Thanks, 
  #     140Kit Team."
  #     recipient = collection.researcher.email
  #     p = PendingEmail.new({:recipient => recipient, :subject => subject, :message_content => message_content}).save
  #   end
  # end
  # 
  # def self.generate_scrape_failed_email(curation)
  #   subject = "Your Scrape failed to collect any data."
  #   message_content = "We ran the term that you threw in (\"#{curation.name}\") and did everything according to specification.
  #   Unfortunately, however, the data never came through - when we were ticking this job off and sending it to analysis, we found that it actually contained 0 tweets, which means it has to be thrown out. 
  #   Please feel free to submit another job. (The likely reasons this job failed: the term did not have enough traffic around it/the users you searched for did not exist)
  #   Thanks, 
  #   140Kit Team."
  #   recipient = curation.researcher.email
  #   p = PendingEmail.new({:recipient => recipient, :subject => subject, :message_content => message_content}).save
  # end
  # 
  # def self.update_time
  #   si = AnalyticalInstance.find({:instance_id => $w.instance_id})
  #   si.updated_at = Time.ntp
  #   si.save
  # end

  #deprecated:
  # def self.create_singular_analysis_metadatas(collection)
  #   analytical_offerings = AnalyticalOffering.find_all({:enabled => true})
  #   new_analysis_metadatas = []
  #   analytical_offerings.each do |ao|
  #     if Analysis.proper_access_level(collection.researcher.role, ao.access_level)
  #       new_am = {}
  #       new_am["function"] = ao.function
  #       new_am["save_path"] = ao.save_path
  #       new_am["collection_id"] = collection.id
  #       new_am["rest"] = ao.rest
  #       new_analysis_metadatas << new_am
  #     end
  #   end
  #   Database.save_all({:analysis_metadatas => new_analysis_metadatas})
  # end
  
  
        # set analyzed datasets to analyzed
        # datasets = Dataset.find_all({:scrape_finished => true, :analyzed => false})
        # for dataset in datasets
        #   # if the num of finished metadatas == total metadatas and total != 0
        #   unfinished = AnalysisMetadata.count({:dataset_id => dataset.id, :finished => false})
        #   if unfinished == 0
        #     total = AnalysisMetadata.count({:dataset_id => dataset.id})
        #     if total > 0
        #       dataset.analyzed = true
        #       dataset.save
        #     else
        #       # spawn analysis jobs
        #       self.spawn_analysis_metadatas(dataset)
        #     end
        #   end
        # end

      #deprecated:
      # def self.finish_scrapes
      #   scrapes = Scrape.find_all({:finished => false, :scrape_finished => true})
      #   for scrape in scrapes
      #     if scrape.class != NilClass && (!scrape.flagged || scrape.instance_id == $w.instance_id)
      #       scrape.flagged = true
      #       scrape.instance_id = $w.instance_id
      #       scrape.save
      #       sleep(SLEEP_CONSTANT)
      #       scrape = Scrape.find({:instance_id => $w.instance_id, :id => scrape.id})
      #       if scrape.class != NilClass && scrape.instance_id == $w.instance_id
      #         datasets = Collection.find_all({:scrape_id => scrape.id, :single_dataset => true}).compact
      #         collection = scrape.collection
      #         datasets.each do |d|
      #           d.tweets_count = Tweet.count({:metadata_id => d.metadata.id, :metadata_type => d.metadata.class.underscore.chop}) if !d.metadata.nil?
      #           d.users_count = User.count({:metadata_id => d.metadata.id, :metadata_type => d.metadata.class.underscore.chop}) if !d.metadata.nil?
      #           d.finished = true
      #         end
      #         datasets.each {|d| AnalysisFlow.create_singular_analysis_metadatas(d) if d.tweets_count != 0}
      #         collection.tweets_count = datasets.collect{|d| d.tweets_count}.sum if !collection.nil?
      #         collection.users_count = datasets.collect{|d| d.users_count}.sum if !collection.nil?
      #         if collection.nil? || collection.tweets_count == 0
      #           self.generate_scrape_failed_email(collection) if !collection.nil?
      #           metadatas = datasets.collect{|d| d.metadata}.compact
      #           metadatas.collect{|m| m.destroy}
      #           datasets.collect{|d| d.destroy}
      #           collection.destroy if !collection.nil?
      #           scrape = scrape.destroy
      #         else
      #           AnalysisFlow.create_singular_analysis_metadatas(collection) 
      #           collection.finished = true
      #           Collection.update_all(datasets.collect{|d| d.attributes}<<collection.attributes)
      #           scrape.finished = true
      #           scrape.save
      #           puts "-+"*20
      #           puts "SCRAPE #{scrape.id} IS TOTALLY FINISHED!"
      #           puts "-+"*20
      #           self.generate_scrape_done_email(collection)
      #         end
      #       end
      #       if scrape.class != NilClass
      #         scrape.flagged = false
      #         scrape.instance_id = ""
      #         scrape.save
      #       end
      #     end
      #   end
      # end
  
end

worker = Worker.new
worker.work