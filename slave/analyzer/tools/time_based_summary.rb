def time_based_summary(collection_id, save_path)
  granularity = "hour"
  time_queries = resolve_time_query(granularity)
  time_queries.each_pair do |time_granularity,time_query|
    collection = Collection.find({:id => collection_id})
    user_timeline = Database.result("select date_format(created_at, '#{time_query}') as created_at from users"+Analysis.conditional(collection)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
    tweet_timeline = Database.result("select date_format(created_at, '#{time_query}') as created_at from tweets"+Analysis.conditional(collection)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
    time_based_analytics("tweets", time_query, tweet_timeline, collection, time_granularity, save_path)
    time_based_analytics("users", time_query, user_timeline, collection, time_granularity, save_path)
  end
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
    conditional = Analysis.conditional(collection)+" and "+Analysis.time_conditional("created_at", object_group["created_at"], granularity)#" and date_format(created_at, '#{time_query}') = '#{object_group["created_at"]}'"
    totals_hash = {}
    case model
    when "tweets"
      frequency_listing = get_frequency_listing("select text from tweets "+Analysis.conditional(collection)+" and "+Analysis.time_conditional("created_at", object_group["created_at"], granularity))
      generate_graph_points([
        {"model" => Tweet, "attribute" => "language", "conditional" => conditional, "style" => "histogram", "title" => "tweet_language", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => Tweet, "attribute" => "created_at", "conditional" => conditional, "style" => "histogram", "title" => "tweet_created_at", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => Tweet, "attribute" => "source", "conditional" => conditional, "style" => "histogram", "title" => "tweet_source", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => Tweet, "attribute" => "location", "conditional" => conditional, "style" => "histogram", "title" => "tweet_location", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity}
      ])
      generate_graph_points([{"title" => "hashtags", "style" => "word_frequency", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"title" => "mentions", "style" => "word_frequency", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"title" => "significant_words", "style" => "word_frequency", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"title" => "urls", "style" => "word_frequency", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity}]) do |fs, graph, tmp_folder|
          generate_word_frequency(fs, tmp_folder, frequency_listing, collection, graph)
      end
    when "users"
      generate_graph_points([
        {"model" => User, "attribute" => "followers_count", "conditional" => conditional, "style" => "histogram", "title" => "user_followers_count", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => User, "attribute" => "friends_count", "conditional" => conditional, "style" => "histogram", "title" => "user_friends_count", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => User, "attribute" => "favourites_count", "conditional" => conditional, "style" => "histogram", "title" => "user_favourites_count", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => User, "attribute" => "geo_enabled", "conditional" => conditional, "style" => "histogram", "title" => "user_geo_enabled", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => User, "attribute" => "statuses_count", "conditional" => conditional, "style" => "histogram", "title" => "user_statuses_count", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => User, "attribute" => "lang", "conditional" => conditional, "style" => "histogram", "title" => "user_lang", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => User, "attribute" => "time_zone", "conditional" => conditional, "style" => "histogram", "title" => "user_time_zone", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity},
        {"model" => User, "attribute" => "created_at", "conditional" => conditional, "style" => "histogram", "title" => "user_created_at", "collection" => collection, "time_slice" => object_group["created_at"], "granularity" => granularity}
      ])
    end
  end
end

def resolve_time(granularity, time_slice)
  hour = ""
  date = ""
  month = ""
  year = ""
  time = time_slice.nil? ? "" : time_slice
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