def raw_csv(collection_id)
  collection = Collection.find({:id => collection_id})
  tweet_query = "select screen_name,location,language,lat,in_reply_to_status_id,created_at,lon,in_reply_to_user_id,text,source,favorited,twitter_id,truncated,user_id,in_reply_to_screen_name from tweets "+Analysis.conditional(collection)
  tweets = Database.result(tweet_query)
  user_query = "select profile_background_image_url,screen_name,location,profile_image_url,utc_offset,contributors_enabled,profile_sidebar_fill_color,url,profile_background_tile,profile_sidebar_border_color,created_at,followers_count,notifications,friends_count,protected,description,geo_enabled,profile_background_color,twitter_id,favourites_count,following,profile_text_color,verified,name,lang,time_zone,statuses_count,profile_link_color from users "+Analysis.conditional(collection)
  users = Database.result(user_query)
  session_hash = Digest::SHA1.hexdigest(Time.ntp.to_s+rand(100000).to_s)
  `mkdir ../tmp_files/#{session_hash}/`
  `mkdir ../tmp_files/#{session_hash}/#{collection.folder_name}`
  Analysis.hashes_to_csv("../tmp_files/#{session_hash}/#{collection.folder_name}/tweets.csv", tweets)
  Analysis.hashes_to_csv("../tmp_files/#{session_hash}/#{collection.folder_name}/users.csv", users)
  `zip -r -9 -j ../tmp_files/#{session_hash}/#{collection.folder_name} ../tmp_files/#{session_hash}/#{collection.folder_name}`
  `rsync -r ../tmp_files/#{session_hash}/#{collection.folder_name}.zip #{CSV_ADDRESS}`
  `rm -r ../tmp_files/#{session_hash}`
  if !collection.single_dataset
    recipient = collection.researcher.email
    subject = "#{collection.researcher.user_name}, your raw CSV data for the #{collection.name} data set is complete."
    message_content = "Your CSV files are ready for download. You can grab them by clicking this link: <a href=\"http://140kit.com/files/raw_data/raw_csv/#{collection.folder_name}.zip\">http://140kit.com/files/raw_data/raw_csv/#{collection.folder_name}.zip</a>."
    email = PendingEmail.new({:recipient => recipient, :subject => subject, :message_content => message_content}).save
  end
end