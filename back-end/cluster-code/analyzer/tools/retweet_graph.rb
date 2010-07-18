def retweet_graph(collection_id, save_path)
  collection = Collection.find({:id => collection_id})
  if collection.single_dataset
    m_ids = [collection.metadata.id]
    query  = "select screen_name,twitter_id,in_reply_to_status_id,created_at,in_reply_to_screen_name from tweets"
    query += " where metadata_id = #{collection.metadata.id}"
    query += " and in_reply_to_status_id != 0"
    query += " and metadata_type = '#{collection.metadata.class.underscore.chop}'"
    retweets = Database.result(query)
  else
    m_ids = collection.metadatas.collect{|m| m.id}
    rm_ids = collection.metadatas.collect{|rm| rm.id if rm.class.to_s == "RestMetadata"}.compact
    sm_ids = collection.metadatas.collect{|sm| sm.id if sm.class.to_s == "StreamMetadata"}.compact
    rm_conditional = rm_ids.empty? ? "" : "(metadata_type = 'rest_metadata' and ( metadata_id = '#{rm_ids.join("' or metadata_id = '")}') and in_reply_to_status_id != 0)"
    sm_conditional = sm_ids.empty? ? "" : "(metadata_type = 'stream_metadata' and ( metadata_id = '#{sm_ids.join("' or metadata_id = '")}') and in_reply_to_status_id != 0)"
    if rm_ids.empty?
      conditional = sm_conditional
    elsif sm_ids.empty?
      conditional = rm_conditional
    elsif !rm_ids.empty? && !sm_ids.empty?
      conditional = rm_conditional+" or "+sm_conditional
    end
    retweets = Database.result("select screen_name,twitter_id,in_reply_to_status_id,created_at,in_reply_to_screen_name from tweets where #{conditional}")
  end
  retweet_index = {}
  retweet_user_index = {}
  retweets.each {|st| retweet_index[st["in_reply_to_status_id"]] = st}
  retweets.each {|st| retweet_user_index[st["in_reply_to_screen_name"]] = st}
  all_source_tweet_ids = retweet_index.keys
  all_source_screen_names = retweet_user_index.keys
  query_count = 0
  local_source_tweet_requests = []
  local_source_user_requests = []
  while query_count < all_source_tweet_ids.length
    local_source_tweet_requests << all_source_tweet_ids[query_count..query_count+MAX_OR_STATEMENT_PER_REQUEST]
    query_count = query_count+MAX_OR_STATEMENT_PER_REQUEST > all_source_tweet_ids.length ? all_source_tweet_ids.length : query_count+MAX_OR_STATEMENT_PER_REQUEST
  end
  query_count = 0
  while query_count < all_source_screen_names.length
    local_source_user_requests << all_source_screen_names[query_count..query_count+MAX_OR_STATEMENT_PER_REQUEST]
    query_count = query_count+MAX_OR_STATEMENT_PER_REQUEST > all_source_screen_names.length ? all_source_screen_names.length : query_count+MAX_OR_STATEMENT_PER_REQUEST
  end
  ###########################
  local_source_tweets = local_source_tweet_requests.collect{|lstr| Database.result("select * from tweets where (twitter_id = '#{lstr.join("' or twitter_id = '")}')")}.flatten
  local_source_users = local_source_user_requests.collect{|lsur| Database.result("select * from users where (screen_name = '#{lsur.join("' or screen_name = '")}')")}.flatten
  local_source_tweet_index = {}
  local_source_user_index = {}
  local_source_tweets.each {|st| local_source_tweet_index[st["twitter_id"]] = st}
  local_source_users.each {|su| local_source_user_index[su["screen_name"]] = su}
  remote_source_tweets = retweet_index.dup.keys-local_source_tweet_index.dup.keys
  if retweet_index.keys.length > 0
    retweet_metadata = collection.metadatas.select {|m| m.term == "retweet"}.first
    if retweet_metadata.nil?
      retweet_metadata = StreamMetadata.new({:finished => false, :term => 'retweet', :researcher_id => collection.researcher_id, :created_at => Time.ntp, :updated_at => Time.ntp, :collection_id => collection_id}).update
      cm = CollectionsStreamMetadata.new({:collection_id => collection_id, :stream_metadata_id => retweet_metadata.id}).update
    end
    graph = generate_graph("retweet", "Network Map", collection_id)
    edges = []
    users = []
    tweets = []
    tweets_count, users_count = 0, 0
    counter = 0
    ###########################
    retweets.each do |retweet|
      tweet, user = determine_source_tweet(retweet, retweet_metadata, m_ids, local_source_tweet_index, local_source_user_index)
      puts "User: #{user.class == Hash ? user["screen_name"] : user.inspect }"
      puts "Tweet: #{tweet.class == Hash ? tweet["twitter_id"] : tweet.inspect}"
      start_node = retweet["in_reply_to_screen_name"]
      if start_node.nil?
        start_node = user["screen_name"]
      end
      edges << {
        :start_node => start_node,
        :end_node => retweet["screen_name"],
        :edge_id => retweet["twitter_id"],
        :time => retweet["created_at"],
        :graph_id => retweet_graph.id,
        :collection_id => collection_id  
      }
      counter += 1
      if user.class == Hash && tweet.class == Hash
        tweets << add_metadata_data(tweet, retweet_metadata.id) if tweet["metadata_id"] != retweet_metadata.id
        users << add_metadata_data(user, retweet_metadata.id) if user["metadata_id"] != retweet_metadata.id
      end
      if counter % MAX_ROW_COUNT_PER_BATCH == 0
        users = users.uniq.compact; tweets = tweets.uniq.compact; edges = edges.uniq.compact
        users_count += users.length
        tweets_count += tweets.length
        Database.update_all({"users" => users})
        Database.update_all({"tweets" => tweets})
        Database.update_all({"edges" => edges})
        users.clear; tweets.clear; edges.clear
        counter = 0
      end
    end
    users = users.uniq.compact; tweets = tweets.uniq.compact; edges = edges.uniq.compact
    users_count += users.length
    tweets_count += tweets.length
    Database.update_all({"users" => users})
    Database.update_all({"tweets" => tweets})
    Database.update_all({"edges" => edges})
    Database.update_attributes(:graphs, [retweet_graph], {:written => true})
    retweet_metadata.tweets_count = tweets_count
    retweet_metadata.users_count = users_count
    retweet_metadata.update
  end
end

def determine_source_tweet(retweet, retweet_metadata, m_ids, local_source_tweet_index, local_source_user_index)
  source_tweet = local_source_tweet_index[retweet["in_reply_to_status_id"]]
  if !source_tweet.nil?
    source_user = local_source_user_index[source_tweet["screen_name"]]
    if source_user.nil?
      remote_source_user_data = U.return_data("http://api.twitter.com/1/users/show.json?screen_name=#{source_tweet["screen_name"]}") || ""
      if remote_source_user_data != ""
        source_user = UserHelper.hash_user(JSON.parse(remote_source_user_data))
      else return nil, nil
      end
    end
    source_tweet.delete("id")
    source_tweet.delete("flagged")
    source_tweet.delete("scrape_id")
    source_tweet.delete("instance_id")
    source_user.delete("id")
    source_user.delete("flagged")
    source_user.delete("scrape_id")
    source_user.delete("instance_id")
  else
    remote_source_tweet_data = U.return_data("http://api.twitter.com/1/statuses/show/#{retweet["in_reply_to_status_id"]}.json") || ""
    if remote_source_tweet_data != ""
      source_user = UserHelper.hash_user(JSON.parse(remote_source_tweet_data)["user"])
      source_tweet = TweetHelper.hash_tweet(JSON.parse(remote_source_tweet_data))
    end
  end
  return source_tweet, source_user
end


def add_metadata_data(hash, metadata_id)
  hash["metadata_id"] = metadata_id
  hash["metadata_type"] = "Retweet"
  return hash
end

def generate_graph(style, title, collection_id)
  graph = Graph.find(:style => style, :title => title, :collection_id => collection_id)
  if graph.nil?
    graph = Graph.new({:style => style, :title => title, :collection_id => collection_id}).update
  end
  return graph
end