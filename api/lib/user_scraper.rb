class UserScraper < Scraper
  def self.pull_stat(user_id)
    user = User.find(user_id)
    unless user.nil?
      unless user.stats_checked
        url = "http://twitter.com/users/show/#{user.username}.xml"
        puts "Grabbing data from url: #{url}"
        raw_data = Scraper.return_data(url)
        # print "raw_data is currently: #{raw_data}"
        if Scraper.valid_data(raw_data)
          puts "Updating statistics for user #{user.username}..."
          xml = Hpricot::XML(raw_data)
          user.location = xml.at("time_zone").innerHTML
          user.account_birth = DateTime.parse(xml.at("created_at").innerHTML)
          user.total_tweets = xml.at("statuses_count").innerHTML.to_i
          user.friends = xml.at("friends_count").innerHTML.to_i
          user.followers = xml.at("followers_count").innerHTML.to_i
          user.stats_checked = true
          user.pending_for_job = false
          user.save!
          puts "Stats updated for #{user.username}"
        else
          puts "Raw data is invalid. It : #{raw_data}\n" 
        end
      else
        puts "Stats have already been pulled for user #{user.username}"
      end
    else
      puts "No user exists with id #{user_id}"
    end
  end
end