def word_frequency(collection_id, save_path)
  collection = Collection.find({:id => collection_id})
  query = "select text from tweets "+Analysis.conditional(collection)
  frequency_listing = get_frequency_listing(query)
  generate_graph_points([{"title" => "hashtags", "style" => "word_frequency", "collection" => collection},
    {"title" => "mentions", "style" => "word_frequency", "collection" => collection},
    {"title" => "significant_words", "style" => "word_frequency", "collection" => collection},
    {"title" => "urls", "style" => "word_frequency", "collection" => collection}]) do |fs, graph, tmp_folder|
      generate_word_frequency(fs, tmp_folder, frequency_listing, collection, graph)
  end
  FilePathing.push_tmp_folder(save_path)
  recipient = collection.researcher.email
  subject = "#{collection.researcher.user_name}, your word frequency charts for the \"#{collection.name}\" data set is complete."
  message_content = "Your CSV files are ready for download. You can grab them by visiting the collection's page: <a href=\"http://140kit.com/#{collection.researcher.user_name}/collections/#{collection.id}\">http://140kit.com/#{collection.researcher.user_name}/collections/#{collection.id}</a>."
  send_email(recipient, subject, message_content, collection)
end

def get_frequency_listing(query)
  frequency_listing = {}
  num = 1
  objects = Database.spooled_result(query)
  while row = objects.fetch_row do
    num+=1
    row.first.super_split(" ").collect do |word|
      word = word.super_strip.downcase
      frequency_listing[word].nil? ? frequency_listing[word] = 1 : frequency_listing[word]+= 1
    end
  end
  Database.terminate_spooling
  objects.free
  return frequency_listing
end

def generate_word_frequency(fs, tmp_folder, frequency_listing, collection, graph)
  FasterCSV.open(tmp_folder+fs["title"]+".csv", "w") do |csv|
    csv << ["word", "occurrences"]
    graph_points = Pretty.pretty_up_labels(fs["style"], fs["title"], eval("hashes_to_graph_points(#{fs["title"]}(frequency_listing), collection, graph)"))
    graph_points.each do |row|
      csv << [row["label"],row["value"]]
    end
    @graph_points+=graph_points
  end
  check_for_save
end

def hashtags(frequency_listing)
  frequency_listing.reject{|k,v| !k.match(/^#/)}
end

def mentions(frequency_listing)
  new_listing = {}
  frequency_listing.reject{|k,v| !k.match(/^@/)}.each_pair do |k,v|
    new_k = k.gsub(/[.?*!:]/, "")
    if new_listing[new_k]
      new_listing[new_k] += v
    else
      new_listing[new_k] = v
    end
  end
  return new_listing
end

def significant_words(frequency_listing)
  stop_words = File.open(ROOT_FOLDER+"cluster-code/analyzer/resources/stop_words.txt").read.split
  frequency_listing.reject{|k,v| stop_words.include?(k) || k.include?("@") || k.include?("#")|| k.include?("http")}
end

def urls(frequency_listing)
  frequency_listing.reject{|k,v| !k.include?("http")}
end

def hashes_to_graph_points(hash, collection, graph)
  temp_graph_points = []
  hash.each_pair do |k,v|
    graph_point = {}
    graph_point["label"] = k
    graph_point["value"] = v
    graph_point["graph_id"] = graph.id
    graph_point["collection_id"] = collection.id
    temp_graph_points << graph_point
  end
  return temp_graph_points
end