#Results: Frequency Charts of basic data on Tweets and Users per data set
def basic_histograms(collection_id, save_path)
  collection = Collection.find({:id => collection_id})
  conditional = Analysis.conditional(collection)
  tweet_languages = Analysis.frequency_hash(Tweet, "language", conditional)
  tweet_created_ats = Analysis.frequency_hash(Tweet, "created_at", conditional)
  tweet_sources = Analysis.frequency_hash(Tweet, "source", conditional)
  tweet_locations = Analysis.frequency_hash(Tweet, "location", conditional)
  user_followers_counts = Analysis.frequency_hash(User, "followers_count", conditional)
  user_friends_counts = Analysis.frequency_hash(User, "friends_count", conditional)
  user_favourites_counts = Analysis.frequency_hash(User, "favourites_count", conditional)
  user_geo_enableds = Analysis.frequency_hash(User, "geo_enabled", conditional)
  user_statuses_counts = Analysis.frequency_hash(User, "statuses_count", conditional)
  user_langs = Analysis.frequency_hash(User, "lang", conditional)
  user_time_zones = Analysis.frequency_hash(User, "time_zone", conditional)
  user_created_ats = Analysis.frequency_hash(User, "created_at", conditional)
  tweet_hashes =   [
    {"style" => "histogram", "title" => "tweet_language", "collection" => collection, "graph_points" => tweet_languages},
    {"style" => "histogram", "title" => "tweet_created_at", "collection" => collection, "graph_points" => tweet_created_ats},
    {"style" => "histogram", "title" => "tweet_source", "collection" => collection, "graph_points" => tweet_sources},
    {"style" => "histogram", "title" => "tweet_location", "collection" => collection, "graph_points" => tweet_locations}
  ]
  user_hashes = [
    {"style" => "histogram", "title" => "user_followers_count", "collection" => collection, "graph_points" => user_followers_counts},
    {"style" => "histogram", "title" => "user_friends_count", "collection" => collection, "graph_points" => user_friends_counts},
    {"style" => "histogram", "title" => "user_favourites_count", "collection" => collection, "graph_points" => user_favourites_counts},
    {"style" => "histogram", "title" => "user_geo_enabled", "collection" => collection, "graph_points" => user_geo_enableds},
    {"style" => "histogram", "title" => "user_favourites_count", "collection" => collection, "graph_points" => user_favourites_counts},
    {"style" => "histogram", "title" => "user_statuses_count", "collection" => collection, "graph_points" => user_statuses_counts},
    {"style" => "histogram", "title" => "user_lang", "collection" => collection, "graph_points" => user_langs},
    {"style" => "histogram", "title" => "user_time_zone", "collection" => collection, "graph_points" => user_time_zones},
    {"style" => "histogram", "title" => "user_created_at", "collection" => collection, "graph_points" => user_created_ats}
  ]
  tweet_graph_points, tweet_graphs = graph_point_creator(tweet_hashes)
  user_graph_points, user_graphs = graph_point_creator(user_hashes)
  Database.update_attributes(:graphs, tweet_graphs+user_graphs, {:written => true})
  Database.update_all({:graph_points => tweet_graph_points+user_graph_points})
  graph_writer((tweet_graphs+user_graphs).flatten.collect{|g| g.id}, save_path, collection)
  recipient = collection.researcher.email
  subject = "#{collection.researcher.user_name}, the raw Graph data for the basic histograms in the \"#{collection.name}\" data set is complete."
  message_content = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{collection.researcher.user_name}/collections/#{collection.id}\">http://140kit.com/#{collection.researcher.user_name}/collections/#{collection.id}</a>."
  send_email(recipient, subject, message_content, collection)  
end

def send_email(recipient, subject, message_content, collection)
  if !collection.single_dataset
    email = PendingEmail.new({:recipient => recipient, :subject => subject, :message_content => message_content}).save
  end
end

def graph_point_creator(graph_hashes)
  graph_points = []
  graphs = []
  finished_graphs = []
  graph_hashes.each do |k|
    time, hour, date, month, year = resolve_time(k["granularity"], k["time_slice"])
    g = generate_graph({:style => k["style"], :title => k["title"], :collection_id => k["collection"].id, :time_slice => time, :hour => hour, :date => date, :month => month, :year => year})
    ugly_graph_points = []
    k["graph_points"].each_pair do |l, w|
      graph_point = {}
      if l.class == NilClass || (l.class == String && l.empty?)
        l = "Not Reported"
      else 
        l.to_s.gsub("\n", " ")
      end
      graph_point["label"] = l
      graph_point["value"] = w.to_s.gsub("\n", " ")
      graph_point["graph_id"] = g.id
      graph_point["collection_id"] = k["collection"].id
      ugly_graph_points << graph_point
    end
    graph_points += Pretty.pretty_up_labels(k["style"], k["title"], ugly_graph_points)
    graphs << g
  end
  return graph_points, graphs
end

def graph_writer(graph_ids, save_path, collection, granularity="", format="csv")
  require 'fastercsv'
  graph_ids.each do |graph_id|
    graph = Graph.find({:id => graph_id})
    sub_folder = [graph.year, graph.month, graph.date, graph.hour].join("/")
    tmp_folder = FilePathing.tmp_folder(collection, sub_folder)
    objects = Database.spooled_result("select * from graph_points where graph_id = #{graph.id}")
    case format
    when "csv"
      keys = ["label", "value"]
      FasterCSV.open(tmp_folder+graph.title, "w") do |csv|
        csv << keys
        num=1
        while row = objects.fetch_hash do
          num+=1
          csv << keys.collect{|key| row[key]}
        end
      end
    end
    objects.free
    Database.terminate_spooling
  end
end