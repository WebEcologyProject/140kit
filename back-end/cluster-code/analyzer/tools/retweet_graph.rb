def retweet_graph(collection_id, save_path)
  collection = Collection.find({:id => collection_id})
  retweet_graph = generate_graph({:style => "retweet", :title => "Network Map", :collection_id => collection_id})
  #save into separate var in the unlikely case that there are not any retweets of any sort
  last_id_results = Database.result("select twitter_id from tweets"+Analysis.conditional(collection)+" and in_reply_to_screen_name != '' order by twitter_id desc limit 1")
  if !last_id_results.empty?
    overall_last_id = last_id_results.first.values.first
    last_id = 0
    num = 0
    finished = false
    while !finished
      query = "select screen_name,twitter_id,in_reply_to_status_id,created_at,in_reply_to_screen_name from tweets"+Analysis.conditional(collection)+" and in_reply_to_screen_name != ''"# and twitter_id > #{last_id} order by twitter_id asc limit #{MAX_ROW_COUNT_PER_BATCH}"
      edges = []
      objects = Database.spooled_result(query)
      while row = objects.fetch_hash do
        edge = {}
        num+=1
        if row["in_reply_to_status_id"] == "0"
          edge["style"] = "mention"
        else
          edge["style"] = "retweet"
        end
        edge["start_node"] = row["in_reply_to_screen_name"]
        edge["end_node"] = row["screen_name"]
        edge["edge_id"] = row["twitter_id"]
        edge["time"] = row["created_at"]
        edge["graph_id"] = retweet_graph.id
        edge["collection_id"] = collection_id
        puts "Edge: FROM: #{edge["start_node"]} TO: #{edge["end_node"]} ID: #{edge["edge_id"]}"
        edges << edge
        last_id = edge["edge_id"]
        if last_id.to_i == overall_last_id
          finished = true
        end
      end
      objects.free
      Database.terminate_spooling  
      Database.update_all({"edges" => edges})
      edges.clear
    end
  end
  retweet_graph.written = true
  retweet_graph.save
end

def generate_graph(attribute_hash)
  graph = Graph.find(attribute_hash)
  if graph.nil?
    graph = Graph.new(attribute_hash).update
  end
  return graph
end