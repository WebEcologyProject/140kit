load "run.rb"
require 'fastercsv'
ids = []
FasterCSV.foreach("../../files/oldspice.csv") do |row|
ids<< row[3]
end

scrape = Scrape.find({:id => 562})
metadata = scrape.metadatas.first
ids.each do |id|
  debugger
  url = "http://api.twitter.com/1/statuses/show/#{id}.json"
  data = U.return_data(url)
  if !data.nil?
    data = JSON.parse(data)
    if !data.empty?
      user = UserHelper.hash_user(data["user"])
      tweet = TweetHelper.hash_tweets([data])
    end
  end
  users << user
  tweets << tweet
  if users.length > MAX_ROW_COUNT_PER_BATCH 
    U.append_scrape_id({:users => users, :tweets => tweets}, metadata)
    Database.save_all(:tweets => tweets)
    Database.save_all(:users => users)
  end
end
  
# $w = Worker.new("worker-3")
# time_based_summary(975, "/raw_data/word_frequencies/")