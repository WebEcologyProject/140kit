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
  
  graph_hashes = {"tweet_language" => tweet_languages, "tweet_created_at" => tweet_created_ats, "tweet_source" => tweet_sources, 
  "tweet_location" => tweet_locations, "user_followers_count" => user_followers_counts, "user_friends_count" => user_friends_counts,
  "user_favourites_count" => user_favourites_counts, "user_geo_enabled" => user_geo_enableds, "user_statuses_count" => user_statuses_counts,
  "user_lang" => user_langs, "user_time_zone" => user_time_zones, "user_created_at" => user_created_ats}
  graph_points = []
  finished_graphs = []
  graph_hashes.each_pair do |k, v|
    t = Time.ntp
    g = generate_graph("histogram", k, collection_id)
    ugly_graph_points = []
    v.each_pair do |l, w|
      graph_point = {}
      if l.class == NilClass || (l.class == String && l.empty?)
        l = "Not Reported"
      else 
        l.to_s.gsub("\n", " ")
      end
      graph_point["label"] = l
      graph_point["value"] = w.to_s.gsub("\n", " ")
      graph_point["graph_id"] = g.id
      graph_point["collection_id"] = collection.id
      ugly_graph_points << graph_point
    end
    graph_points = graph_points+Pretty.pretty_up_labels(k, ugly_graph_points) if !ugly_graph_points.nil? && !ugly_graph_points.empty?
    finished_graphs << g
  end
  Database.update_all({"graph_points" => graph_points})
  tmp_folder = FilePathing.tmp_folder(collection)
  graph_hashes.each_pair do |k,v|
    row_hashes = []
    v.collect{|l,w| row_hashes << {"label" => l, "value" => w}}
    Analysis.hashes_to_csv(row_hashes, "#{k}.csv")
  end
  FilePathing.push_tmp_folder(save_path)
  recipient = collection.researcher.email
  subject = "#{collection.researcher.user_name}, the raw Graph data for the basic histograms in the \"#{collection.name}\" data set is complete."
  message_content = "Your CSV files are ready for download. You can grab them by clicking this link: <a href=\"http://140kit.com/files/raw_data/graph_points/#{collection.folder_name}.zip\">http://140kit.com/files/raw_data/graph_points/#{collection.folder_name}.zip</a>."
  send_email(recipient, subject, message_content, collection)
  Database.update_attributes(:graphs, finished_graphs, {:written => true})
end

def send_email(recipient, subject, message_content, collection)
  if !collection.single_dataset
    email = PendingEmail.new({:recipient => recipient, :subject => subject, :message_content => message_content}).save
  end
end