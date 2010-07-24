def time_based_summary(collection_id, save_path)
  time_granularity = "year"
  time_query = resolve_time_query(time_granularity)
  collection = Collection.find({:id => collection_id})
  user_timeline = Database.result("select count(*),date_format(created_at, '#{time_query}') as created_at from users"+Analysis.conditional(collection)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
  tweet_timeline = Database.result("select count(*),date_format(created_at, '#{time_query}') as created_at from tweets"+Analysis.conditional(collection)+"group by date_format(created_at, '#{time_query}') order by created_at desc")
  time_based_analytics("users", ["screen_name","followers_count","friends_count","favourites_count","utc_offset","statuses_count","lang"], time_query, user_timeline, collection, time_granularity)
end

def resolve_time_query(time_granularity)
  case time_granularity
  when "year"
    return "%Y"
  when "month"
    return "%Y-%m"
  when "date"
    return "%Y-%m-%e"
  when "hour"
    return "%Y-%m-%e %H"
  when "minute"
    return "%Y-%m-%e %H:%i"
  end
end

def time_based_analytics(model, attributes, time_query, object_timeline, collection, granularity)
  done = false
  graph_points = []
  graphs = []
  object_timeline.each do |object_group|
    conditional = Analysis.conditional(collection)+" and date_format(created_at, '#{time_query}') = '#{object_group["created_at"]}'"
    totals_hash = {}
    case model
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
    if graph_points.length > MAX_ROW_COUNT_PER_BATCH
      Database.update_all({"graph_points" => graph_points})
      graph_points = []
    end
    if graphs.length > MAX_ROW_COUNT_PER_BATCH
      Database.update_attributes(:graphs, graphs, {:written => true})
      graphs = []
    end
  end
  Database.update_all({"graph_points" => graph_points})
  Database.update_attributes(:graphs, graphs, {:written => true})
end