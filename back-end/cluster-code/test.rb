load "run.rb"
$w = Worker.new("worker-3")
Analysis.time_conditional("created_at", "2010-02-03 06", "hour")
# basic_histograms(1437, "/raw_data/graph_points")
# require 'fastercsv'
# ids = []
# FasterCSV.foreach("../../files/oldspice.csv") do |row|
# ids<< row[3]
# end
# 
# scrape = Scrape.find({:id => 562})
# metadata = scrape.metadatas.first
# users = []
# tweets = []
# ids.each do |id|
#   url = "http://api.twitter.com/1/statuses/show/#{id}.json"
#   data = U.return_data(url)
#   if !data.nil?
#     data = JSON.parse(data)
#     if !data.empty?
#       user = UserHelper.hash_user(data["user"])
#       tweet = TweetHelper.hash_tweet(data)
#     end
#     users << user
#     tweets << tweet
#   end
#   if users.length > MAX_ROW_COUNT_PER_BATCH 
#     U.append_scrape_id({:users => users, :tweets => tweets}, metadata)
#     Database.save_all(:tweets => tweets)
#     Database.save_all(:users => users)
#     users = []
#     tweets = []
#   end
# end
# Database.save_all(:tweets => tweets)
# Database.save_all(:users => users)
#   
# $w = Worker.new("worker-3")
# word_frequency(1449, "/raw_data/gender_estimation/")