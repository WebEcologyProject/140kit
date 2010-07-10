class SeedScraper < Scraper
  def self.raw_grab(term, scrape_id, first_run)
    # formats term to handle special characters in the url:
    # a quick fix that handles spaces, @s, #s, quotes, etc.
    # may not handle some of the other twitter operators well such as "OR" or "-"
    formatted_term = ""
    for char in term.split('')
      unless char == " "
        formatted_term += "%" + char.unpack('U')[0].to_s(16)
      else
        formatted_term += "+"
      end
    end
  
    url = "http://search.twitter.com/search.atom?q=#{formatted_term}&rpp=100"
    puts "Fetching tweets from #{url}..."

    if first_run
      raw_data = [scrape_id, ",", first_run, ",", Scraper.return_data(url)].to_s
    else
      raw_data = [scrape_id, ",", first_run, ",", Scraper.return_data(url)].to_s
    end
    return raw_data
  end
  
  def self.pars(raw_data, scrape_id)
    if Scraper.valid_data(raw_data)
      xml = Hpricot::XML(raw_data)
      puts "Retrieved " + (xml/:entry).length.to_s + " new tweets"
      try_count = 0
      unique_tweet_count = 0
      (xml/:entry).each do |entry|
        begin
          twitter_id = (entry/:id).inner_html.gsub("tag:search.twitter.com,2005:", "").to_i
          if Tweet.find_by_twitter_id(twitter_id).nil?
            print "Tweet " + twitter_id.to_s + " doesn't exist. creating a new tweet...\n"
            tweet = Tweet.new
            tweet.twitter_id = twitter_id
            tweet.published = DateTime.parse((entry/:published).inner_html)
            tweet.message = (entry/:title).inner_html
            tweet.language = entry.at('twitter:lang').inner_html
            tweet.scrape_id = scrape_id
            username = (entry/:author/:uri).inner_html.gsub("http://twitter.com/", "")
            print "Found tweet from " + username + "\n"
            user = User.find_by_username(username)
            if user.nil?
              print username + " doesn't exist. creating a new user...\n"
              user = User.new
              user.username = username
              user.scrape_id = scrape_id
              user.save!
              tweet.user_id = user.id
            else
              print username + " exists. adding tweet to user.\n"
              tweet.user_id = user.id
            end
            tweet.save!
            unique_tweet_count += 1
          else print "Tweet exists\n"
          end
          try_count += 1
        rescue Exception => e
          puts e
          puts "#{(xml/:entry).length - try_count - 1} tweets left in this batch."
          print "Moving on...\n"
          next
        end
      end
      print "Found " + unique_tweet_count.to_s + " unique tweets\n"
    else print "DATA IS INVALID\n"
    end
    print "Finished a pars task\n"
    Scrape.find(scrape_id).make_new_stat_job
  end
  
end