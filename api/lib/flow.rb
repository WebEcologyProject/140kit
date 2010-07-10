class Flow
  require "open-uri"
  require "hpricot"  
  # WELCOME TO THE CAREER CENTER #
#   Jobs can be described as either being passive or being active. Jobs that are active are suffixed with
#  _job, such as stat_job, anal_job, etc..., whereas passive jobs are suffixed with _seed, such as stat_seed.
  def self.poll
    while true
      $me = Worker.new
      $me.idle = true
      $me.job_id = 0
      $me.save!
      begin
        print "Polling for new available jobs...\n"
        if Job.count(:conditions => {:available => true, :finished => false}) > 0
          job = Job.find(:first, :conditions => {:available => true, :finished => false}, :lock => true)
          handle_job($me, job)
        else sleep(10)
        end
      rescue => e
        puts e
        if job != nil && !job.valid?
          # make invalid job unavailable
          job.available = false
          job.data_hash = "INVALID_JOB_#{job.id}"
          job.save!
        end
        fail = Failure.new
        fail.message = e.to_s.split(/\n/).first
        fail.trace = e.to_s.split(/\n/) - [e.to_s.split(/\n/).first]
        # Right here, we would want fail.scrape_id = scrape.id|job.scrape_id|something like that,
        # but that would break the rule of having agnostic jobs
        fail.save!
        next
      end
      $me.destroy
    end
  end
  def self.handle_job(worker, job)
    if job != nil && job.available && !job.finished # double check incase another worker was waiting on the lock, and also start with a nil check in case one finished between queries
      print "\n\n\n\n////////////////////////////////////////////////////////////\n\n"
      print "Found a new job with ID #{job.id} at #{Time.now.to_s}\n"
      print "\n////////////////////////////////////////////////////////////\n\n\n\n\n"
      job.available = false
      job.save!
      worker.idle = false
      worker.job = job
      worker.job_id = job.id
      worker.save!
      finished = route_job(job.task_type, job.data, worker)
      worker.idle = true
      worker.job = nil
      worker.job_id = 0
      worker.save!
      job.finished = finished if finished
      job.save!
    end
  end
  def self.route_job(task_type, job_data, worker)
    puts "Routing job..."
    sleep 5
    if worker.id != Job.find(worker.job.id).worker_id
      return false
    else
      finish_route(task_type, job_data)
      return true
    end
  end
  
  def self.finish_route(task_type, job_data)    
    if task_type == "mail" && $SMTP == true
      mail_job(job_data)
    else    
      case task_type
        when "ping"
          ping_job(job_data)
        when "pars"
          pars_job(job_data)
        when "stat"
          stat_job(job_data)
        when "anal"
          anal_job(job_data)
        when "maps"
          maps_job(job_data)
        when "done"
          done_job(job_data)
        else print "Invalid task type: #{task_type}\n"
      end
    end
  end
  
  def self.ping_job(job_data)
    puts "Starting a Ping job..."
    #print "Ping job looks like: #{job_data}\n"
    data = job_data.split(',')
    if data.length == 4
      scrape = Scrape.new
      scrape.term = data[0]
      scrape.length = data[1].to_i
      scrape.granularity = data[2].to_i
      scrape.email_address = data[3]
      scrape.folder_name = "#{scrape.term}_#{Time.now.to_s.gsub(' ', '\ ')}"
      scrape.save!
      scrape.ping_task
    else print "Invalid job data\n"
    end
  end
  
  def self.pars_job(job_data)
    puts "Starting a Pars job..."
    #print "Pars job looks like: #{job_data}\n"
    raw_data, scrape_id = clean_for_uniqueness(job_data)
    SeedScraper.pars(raw_data, scrape_id)
  end
  
  def self.stat_job(job_data)
    puts "Starting a Stat job..."
    #print "Stat job looks like: #{job_data}\n"
    user_ids = job_data.split(',')
    scrape = Scrape.find(user_ids.shift)
    scrape.stat_task(user_ids)
  end
  
  def self.anal_job(job_data)
    puts "Starting an Anal job..."
    #print "Anal job looks like: #{job_data}\n"
    user_ids = job_data.split(',')
    scrape = Scrape.find(user_ids.shift)
    scrape.anal_task(user_ids)
  end
  
  def self.done_job(job_data)
    puts "Starting a Done job..."
    #print "Done job looks like: #{job_data}\n"
    scrape_id = job_data
    scrape = Scrape.find(scrape_id)
    scrape.done_task
  end
  
  def self.mail_job(job_data)
    scrape = Scrape.find(job_data)
    AccountMailer.deliver_scrape_finished(scrape) 
  end
  
  def self.clean_for_uniqueness(job_data)
    junk, scrape_id, raw_data = job_data.split(/^(\d*),/)
    junk, first_run, raw_data = raw_data.split(/^(\w*),/)
    scrape_id = scrape_id.to_i
    if first_run == "true"
      entries = Hpricot::XML(raw_data)
      entries = (entries/:entry).to_s
      return [entries, scrape_id]
    else
      pars_jobs = Job.find(:all, :conditions => {:task_type => "pars"}).partition {|j| j.data.split(/^(\d*),/)[1].to_i == scrape_id}.first
      current_job = Job.find_by_data(job_data)
      previous_job = pars_jobs[pars_jobs.index(current_job)-1]
      previous_xml = Hpricot::XML(previous_job.data)
      current_xml = Hpricot::XML(current_job.data)
      previous_xml_array = []
      current_xml_array = []
      (previous_xml/:entry).each {|elem| previous_xml_array << elem.to_s}
      (current_xml/:entry).each {|elem| current_xml_array << elem.to_s}
      unique_xml = (current_xml_array-previous_xml_array).to_s
      return [unique_xml, scrape_id]
    end
  end
  
  def self.start_fresh
    Job.connection.execute("TRUNCATE TABLE `jobs`")
    Tweet.connection.execute("TRUNCATE TABLE `tweets`")
    User.connection.execute("TRUNCATE TABLE `users`")
    Scrape.connection.execute("TRUNCATE TABLE `scrapes`")
    Worker.connection.execute("TRUNCATE TABLE `workers`")
    Analysis.connection.execute("TRUNCATE TABLE `analyses`")
  end
  
end