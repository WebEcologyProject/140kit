def retweet_graph(curation_id, save_path)
  curation = Curation.find({:id => curation_id})
  retweet_graph = generate_graph({:style => "retweet", :title => "Network Map", :curation_id => curation_id})
  # # #save into separate var in the unlikely case that there are not any retweets of any sort
  # last_id_results = Database.result("select twitter_id from tweets"+Analysis.conditional(collection)+" and in_reply_to_screen_name != '' order by twitter_id desc limit 1")
  # if !last_id_results.empty?
  #   overall_last_id = last_id_results.first.values.first
  #   last_id = 0
  #   num = 0
  #   finished = false
  #   while !finished
  #     query = "select screen_name,twitter_id,in_reply_to_status_id,created_at,in_reply_to_screen_name from tweets"+Analysis.conditional(collection)+" and in_reply_to_screen_name != ''"# and twitter_id > #{last_id} order by twitter_id asc limit #{MAX_ROW_COUNT_PER_BATCH}"
  #     @edges = []
  #     objects = Database.spooled_result(query)
  #     while row = objects.fetch_hash do
  #       edge = {}
  #       num+=1
  #       if row["in_reply_to_status_id"] == "0"
  #         edge["style"] = "mention"
  #       else
  #         edge["style"] = "retweet"
  #       end
  #       edge["start_node"] = row["in_reply_to_screen_name"]
  #       edge["end_node"] = row["screen_name"]
  #       edge["edge_id"] = row["twitter_id"]
  #       edge["time"] = row["created_at"]
  #       edge["graph_id"] = retweet_graph.id
  #       edge["collection_id"] = collection_id
  #       puts "Edge: FROM: #{edge["start_node"]} TO: #{edge["end_node"]} ID: #{edge["edge_id"]}"
  #       @edges << edge
  #       last_id = edge["edge_id"]
  #       if last_id.to_i == overall_last_id
  #         finished = true
  #       end
  #       if @edges.length >= MAX_ROW_COUNT_PER_BATCH
  #         Database.update_all({:edges => @edges}, Environment.new_db_connect)
  #         @edges = []
  #       end
  #     end
  #   end
  #   objects.free
  #   Database.terminate_spooling  
  #   Database.update_all({"edges" => @edges})
  #   @edges.clear
  # end
  # retweet_graph.written = true
  # retweet_graph.save
  generate_graphml_files(curation, save_path, retweet_graph)
  FilePathing.push_tmp_folder(save_path)
end

def generate_graph(attribute_hash)
  graph = Graph.find(attribute_hash)
  if graph.nil?
    graph = Graph.new(attribute_hash).update
  end
  return graph
end

def generate_graphml_files(curation, save_path, graph)
  granularity = "hour"
  time_queries = resolve_time_query(granularity)
  time_queries.each_pair do |granularity, time_query|
    edge_timeline = Database.result("select date_format(time, '#{time_query}') as time from edges where graph_id = #{graph.id} group by date_format(time, '#{time_query}') order by time desc")
    edge_timeline.each do |time_set|
      time, hour, date, month, year = resolve_time(granularity, time_set["time"])
      sub_folder = [year, month, date, hour].join("/")
      tmp_folder = FilePathing.tmp_folder(curation, sub_folder)
      query = "select * from edges where "+Analysis.time_conditional("time", time_set["time"], granularity)+" and graph_id = #{graph.id}"
      Graphml.generate_file(query, "full", tmp_folder)
    end
  end
end