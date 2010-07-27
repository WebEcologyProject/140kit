def time_based_summary(collection_id, save_path)
  granularity = "hour"
  time_queries = resolve_time_query(granularity)
  time_queries.each_pair do |time_granularity,time_query|
    collection = Collection.find({:id => collection_id})
    user_timeline = Database.result("select count(*),date_format(created_at, '#{time_query}') as created_at from users"+Analysis.conditional(collection)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
    tweet_timeline = Database.result("select count(*),date_format(created_at, '#{time_query}') as created_at from tweets"+Analysis.conditional(collection)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
    time_based_analytics("tweets", time_query, tweet_timeline, collection, time_granularity, save_path)
    time_based_analytics("users", time_query, user_timeline, collection, time_granularity, save_path)
  end
  debugger
  FilePathing.push_tmp_folder(save_path)
end

def resolve_time_query(time_granularity)
  case time_granularity
  when "year"
    return {"year" => "%Y"}
  when "month"
    return {"year" => "%Y", "month" => "%Y-%m"}
  when "date"
    return {"year" => "%Y", "month" => "%Y-%m", "date" => "%Y-%m-%e"}
  when "hour"
    return {"year" => "%Y", "month" => "%Y-%m", "date" => "%Y-%m-%e", "hour" => "%Y-%m-%e %H"}
  end
end

def time_based_analytics(model, time_query, object_timeline, collection, granularity, save_path)
  object_timeline.each do |object_group|
    temp_save_path = resolve_time(granularity, object_group["created_at"])
    temp_save_path.shift
    graphs = []
    graph_points = []
    conditional = Analysis.conditional(collection)+" and date_format(created_at, '#{time_query}') = '#{object_group["created_at"]}'"
    totals_hash = {}
    case model
    when "tweets"
      tweet_languages = Analysis.frequency_hash(Tweet, "language", conditional)
      tweet_created_ats = Analysis.frequency_hash(Tweet, "created_at", conditional)
      tweet_sources = Analysis.frequency_hash(Tweet, "source", conditional)
      tweet_locations = Analysis.frequency_hash(Tweet, "location", conditional)
      temp_graph_points, temp_graphs = graph_point_creator([
        {"style" => "time_based_histogram", "title" => "tweet_language", "collection" => collection, "graph_points" => tweet_languages, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "tweet_created_at", "collection" => collection, "graph_points" => tweet_created_ats, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "tweet_source", "collection" => collection, "graph_points" => tweet_sources, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "tweet_location", "collection" => collection, "graph_points" => tweet_locations, "time_slice" => object_group["created_at"], "granularity" => granularity}
      ])
      graph_points+=temp_graph_points
      graphs+=temp_graphs
      graphs+=generate_word_frequencies(collection, conditional, granularity, object_group["created_at"])
    when "users"
      user_followers_counts = Analysis.frequency_hash(User, "followers_count", conditional)
      user_friends_counts = Analysis.frequency_hash(User, "friends_count", conditional)
      user_favourites_counts = Analysis.frequency_hash(User, "favourites_count", conditional)
      user_geo_enableds = Analysis.frequency_hash(User, "geo_enabled", conditional)
      user_statuses_counts = Analysis.frequency_hash(User, "statuses_count", conditional)
      user_langs = Analysis.frequency_hash(User, "lang", conditional)
      user_time_zones = Analysis.frequency_hash(User, "time_zone", conditional)
      user_created_ats = Analysis.frequency_hash(User, "created_at", conditional)
      temp_graph_points, temp_graphs = graph_point_creator([{"style" => "time_based_histogram", "title" => "user_followers_count", "collection" => collection, "graph_points" => user_followers_counts, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "user_friends_count", "collection" => collection, "graph_points" => user_friends_counts, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "user_favourites_count", "collection" => collection, "graph_points" => user_favourites_counts, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "user_geo_enabled", "collection" => collection, "graph_points" => user_geo_enableds, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "user_favourites_count", "collection" => collection, "graph_points" => user_favourites_counts, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "user_statuses_count", "collection" => collection, "graph_points" => user_statuses_counts, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "user_lang", "collection" => collection, "graph_points" => user_langs, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "user_time_zone", "collection" => collection, "graph_points" => user_time_zones, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"style" => "time_based_histogram", "title" => "user_created_at", "collection" => collection, "graph_points" => user_created_ats, "time_slice" => object_group["created_at"], "granularity" => granularity}
      ])
      graph_points+=temp_graph_points
      graphs+=temp_graphs
    end
    Database.update_all({"graph_points" => graph_points})
    Database.update_attributes(:graphs, graphs, {:written => true})
    graph_writer(graphs.collect{|g| g.id}, save_path, collection, granularity)
  end
end

def generate_word_frequencies(collection, conditional, granularity, time_slice)
  time, hour, date, month, year = resolve_time(granularity, time_slice)
  frequency_listing = {}
  num = 1
  objects = Database.spooled_result("select text from tweets"+conditional)
  while row = objects.fetch_row do
    num+=1
    row.first.super_split(" ").collect do |word|
      word = word.super_strip
      frequency_listing[word].nil? ? frequency_listing[word] = 1 : frequency_listing[word]+= 1
    end
  end
  objects.free
  Database.terminate_spooling
  hashtags_graph = generate_graph({:style => "word_frequency", :title => "hashtags", :collection_id => collection.id, :time_slice => time, :hour => hour, :date => date, :month => month, :year => year})
  mentions_graph = generate_graph({:style => "word_frequency", :title => "mentions", :collection_id => collection.id, :time_slice => time, :hour => hour, :date => date, :month => month, :year => year})
  no_stop_words_graph = generate_graph({:style => "word_frequency", :title => "significant_words", :collection_id => collection.id, :time_slice => time, :hour => hour, :date => date, :month => month, :year => year})
  urls_graph = generate_graph({:style => "word_frequency", :title => "urls", :collection_id => collection.id, :time_slice => time, :hour => hour, :date => date, :month => month, :year => year})
  hashtags_graph_points = hashes_to_graph_points(hashtags(frequency_listing), collection, hashtags_graph)
  mentions_graph_points = hashes_to_graph_points(mentions(frequency_listing), collection, mentions_graph)
  no_stop_words_graph_points = hashes_to_graph_points(no_stop_words(frequency_listing), collection, no_stop_words_graph)
  urls_graph_points = hashes_to_graph_points(urls(frequency_listing), collection, urls_graph)
  Database.update_all({"graph_points" => hashtags_graph_points+mentions_graph_points+no_stop_words_graph_points+urls_graph_points})
  Database.update_attributes(:graphs, [hashtags_graph, mentions_graph, no_stop_words_graph, urls_graph], {:written => true})
  return [hashtags_graph,mentions_graph,no_stop_words_graph,urls_graph]
end

def resolve_time(granularity, time_slice)
  time = time_slice
  case granularity
  when "hour"
    time = Time.parse(time)
    hour = time.hour
    date = time.day
    month = time.month
    year = time.year
  when "date"
    time = Time.parse(time)
    hour = ""
    date = time.day
    month = time.month
    year = time.year
  when "month"
    time = Time.parse("#{time}-01")
    hour = ""
    date = ""
    month = time.month
    year = time.year
  when "year"
    time = Time.parse("#{time}-01-01")
    hour = ""
    date = ""
    month = ""
    year = time.year
  end
  return time, hour, date, month, year
end
