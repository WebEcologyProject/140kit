def word_frequency(collection_id, save_path)
  collection = Collection.find({:id => collection_id})
  query = "select text from tweets "+Analysis.conditional(collection)
  frequency_listing = {}
  num = 1
  objects = Database.spooled_result(query)
  while row = objects.fetch_row do
    num+=1
    row.first.super_split(" ").collect do |word|
      word = word.super_strip
      frequency_listing[word].nil? ? frequency_listing[word] = 1 : frequency_listing[word]+= 1
    end
  end
  objects.free
  Database.terminate_spooling
  hashtags_graph = generate_graph("word_frequency", "hashtags", collection_id)
  mentions_graph = generate_graph("word_frequency", "mentions", collection_id)
  no_stop_words_graph = generate_graph("word_frequency", "significant_words", collection_id)
  urls_graph = generate_graph("word_frequency", "urls", collection_id)
  hashtags_graph_points = hashes_to_graph_points(hashtags(frequency_listing), collection, hashtags_graph)
  mentions_graph_points = hashes_to_graph_points(mentions(frequency_listing), collection, mentions_graph)
  no_stop_words_graph_points = hashes_to_graph_points(no_stop_words(frequency_listing), collection, no_stop_words_graph)
  urls_graph_points = hashes_to_graph_points(urls(frequency_listing), collection, urls_graph)
  Database.update_all({"graph_points" => hashtags_graph_points+mentions_graph_points+no_stop_words_graph_points+urls_graph_points})
  Database.update_attributes(:graphs, [hashtags_graph, mentions_graph, no_stop_words_graph, urls_graph], {:written => true})
  tmp_folder = FilePathing.tmp_folder(collection)
  graph_hashes = {"no_stop_words" => no_stop_words_graph_points, "urls" => urls_graph_points, "hashtags" => hashtags_graph_points, "mentions" => mentions_graph_points}
  graph_hashes.each_pair do |k,v|
    row_hashes = []
    v.collect{|t| row_hashes << {"label" => t["label"], "value" => t["value"]}}
    Analysis.hashes_to_csv(row_hashes, "#{k}.csv")
  end
  FilePathing.push_tmp_folder(save_path)
  recipient = collection.researcher.email
  subject = "#{collection.researcher.user_name}, your word frequency charts for the \"#{collection.name}\" data set is complete."
  message_content = "Your CSV files are ready for download. You can grab them by clicking this link: <a href=\"http://140kit.com/files/raw_data/graph_points/#{collection.folder_name}.zip\">http://140kit.com/files/raw_data/graph_points/#{collection.folder_name}.zip</a>."
  send_email(recipient, subject, message_content, collection)
end

def hashtags(frequency_listing)
  frequency_listing.reject{|k,v| !k.match(/^#/)}
end

def mentions(frequency_listing)
  frequency_listing.reject{|k,v| !k.match(/^@/)}
end

def no_stop_words(frequency_listing)
  stop_words = File.open(ROOT_FOLDER+"cluster-code/analyzer/resources/stop_words.txt").read.split
  frequency_listing.reject{|k,v| stop_words.include?(k) || k.include?("@") || k.include?("#")}
end

def urls(frequency_listing)
  frequency_listing.reject{|k,v| !k.include?("http")}
end

def hashes_to_graph_points(hash, collection, graph)
  graph_points = []
  hash.each_pair do |k,v|
    graph_point = {}
    graph_point["label"] = k
    graph_point["value"] = v
    graph_point["graph_id"] = graph.id
    graph_point["collection_id"] = collection.id
    graph_points << graph_point
  end
  return graph_points
end