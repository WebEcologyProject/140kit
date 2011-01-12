def gender_estimation(collection_id, save_path)
  collection = Collection.find({:id => collection_id})
  gender_graph = generate_graph({:style => "gender", :title => "User Gender Mapping", :collection_id => collection_id})
  gender_results = generate_graph({:style => "gender", :title => "User Gender Breakdown", :collection_id => collection_id})
  gender_mapping = []
  gender_results_mapping = []
  gender_results_tracker = {}
  objects = Database.spooled_result("select name,twitter_id from users "+Analysis.conditional(collection))
  first_hash = objects.fetch_hash
  keys = first_hash.keys
  while row = objects.fetch_hash do
    query = %(query+gender_common%0Agender+%5Bis+the+likely+gender+inferred+from+the+name%5D+%5Bpersonal+name%3A+%5B%22#{URI.encode(row["name"])}%22%5D%5D%0Agender+%5Bcommonly+translates+as%5D+gender_common)
    c = "http://api.trueknowledge.com/query/?api_account_id=#{Environment.tk_username}&api_password=#{Environment.tk_password}&query=#{query}"
    begin
      result = (value_string = Hpricot(open(c).read).at("tk:id")).nil? ? "inconclusive" : value_string.innerHTML.gsub(/[\[\]\&quot\;]/, "")
    rescue Timeout::Error
      puts "FAIL"
      retry
    end
    graph_point = {}
    graph_point["label"] = row["twitter_id"]
    graph_point["value"] = result
    graph_point["graph_id"] = gender_graph.id
    graph_point["collection_id"] = collection.id
    gender_results_tracker[result].nil? ? gender_results_tracker[result]=1 : gender_results_tracker[result]+=1
    gender_mapping << graph_point
    if gender_mapping.length > MAX_ROW_COUNT_PER_BATCH
      Database.update_all({:graph_points => gender_mapping}, Environment.new_db_connect)
      gender_mapping = []
    end
  end
  gender_results_tracker.each_pair do |k,v|
    graph_point = {}
    graph_point["label"] = k
    graph_point["value"] = v
    graph_point["graph_id"] = gender_results.id
    graph_point["collection_id"] = collection.id    
    gender_results_mapping << graph_point
  end
  objects.free
  Database.terminate_spooling
  Database.update_all({:graph_points => gender_mapping})
  Database.update_all({:graph_points => gender_resupts_mapping})
  Database.update_attributes(:graphs, [gender_graph, gender_results], {:written => true}, Environment.new_db_connect)
end

