def mean_followers(scrape_id)
  puts "#"*10, Analysis.mean(User, "followers_count", {:scrape_id => scrape_id}), "#"*10
  sleep(rand(5))
end