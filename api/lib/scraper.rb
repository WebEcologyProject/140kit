class Scraper
  require "open-uri"
  require "hpricot"

  def self.return_data(url)
    tries = 0
    begin
      raw_data = open(url).read
    rescue Timeout::Error => e
      puts e
      if tries <= 3
        puts "Retrying..."
        tries += 1
        retry
      end
      raw_data = ""
      return raw_data
    rescue => e
      puts e
      if tries <= 3
        puts "Retrying..."
        tries += 1
        retry
      end
      raw_data = ""
      return raw_data
    end
    return raw_data
  end
  
  def self.valid_data(raw_data)    
    if raw_data.blank?
      return false
    elsif raw_data.include?("<error>Not found</error>")
      return false
    elsif raw_data.include?("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">")
      print "Recieved 500 error on the API RPC; going to sleep for one minute, try again.\n"
      sleep(60)
      return false
    elsif raw_data.include?("<statuses type=\"array\">\n</statuses>")
      return false
    else return true
    end
  end
  
  def retryable(options = {}, &block)
    # =>     On the event that a page doesn't get loaded, we will run a retry a
    # =>  few times just for kicks to see if we can retrieve it.
    opts = { :tries => 1, :on => Exception }.merge(options)
    retry_exception, retries = opts[:on], opts[:tries]
    begin
      return yield
    rescue retry_exception
      retry if (retries -= 1) > 0
    end
    yield
  end
end