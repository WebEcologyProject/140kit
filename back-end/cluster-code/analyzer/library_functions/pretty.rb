class Pretty
    def self.pretty_up_labels(graph_title, graphs)
    case graph_title
    when "tweet_language"
      graphs.collect{|graph| graph["label"] = Pretty.language(graph["label"])}
    when "tweet_created_at"
      graphs = Pretty.time_generalize(graphs)
    when "tweet_source"
      graphs.collect{|graph| graph["label"] = Pretty.source(graph["label"])}
    when "user_lang"
      graphs.collect{|graph| graph["label"] = Pretty.language(graph["label"])}
    when "user_geo_enabled"
      graphs.collect{|graph| graph["label"] = Pretty.boolean_fix(graph["label"])}
    when "user_created_at"
      graphs = Pretty.time_generalize(graphs)
    end
    return graphs
  end
  
  def self.language(language)
    language_map = {"en" => "English", "ja" => "Japanese", "it" => "Italian", "de" => "German", "fr" => "French", "kr" => "Korean", "es" => "Spanish"}
    return language_map[language]
  end
    
  def self.source(source)
    if source.include?("</a>")
      source = source.scan(/>(.*)</)[0][0]
    end
    return source.gsub("\"", "\\\"")
  end

  def self.boolean_fix(boolean)
    if boolean
      boolean = "Yes"
    else
      boolean = "No"
    end
    return boolean
  end
  
  def self.time_generalize(graphs)
    sorted_times = graphs.collect{|g| Time.parse(g["label"].to_s).to_i}.sort
    length = sorted_times.last-sorted_times.first
    if length < 60
      new_graphs = Pretty.time_rounder("second", graphs)
    elsif length < 3600
      new_graphs = Pretty.time_rounder("minute", graphs)      
    elsif length < 86400
      new_graphs = Pretty.time_rounder("hour", graphs)
    else 
      new_graphs = Pretty.time_rounder("day", graphs)
    end
  end
  
  def self.time_rounder(granularity, graphs)
    new_graphs = {}
    case granularity
    when "second"
      return graphs
    when "minute"
      graphs.each do |graph|
        if new_graphs[Time.parse(graph["label"].to_s.gsub(/:\d\d .*/, "").gsub(" ", ", ")).to_i.to_s].nil?
          new_graphs[Time.parse(graph["label"].to_s.gsub(/:\d\d .*/, "").gsub(" ", ", ")).to_i.to_s] = {"label" => graph["label"].to_s.gsub(/:\d\d .*/, "").gsub(" ", ", "), "value" => graph["value"].to_i, "collection_id" => graph["collection_id"], "graph_id" => graph["graph_id"]}
        else
          new_graphs[Time.parse(graph["label"].to_s.gsub(/:\d\d .*/, "").gsub(" ", ", ")).to_i.to_s]["value"] += graph["value"].to_i
        end
      end
    when "hour"
      graphs.each do |graph|
        if new_graphs[Time.parse(graph["label"].to_s.gsub(/:\d\d:\d\d .*/, "").gsub(" ", ", ")).to_i.to_s].nil?
          new_graphs[Time.parse(graph["label"].to_s.gsub(/:\d\d:\d\d .*/, "").gsub(" ", ", ")).to_i.to_s] = {"label" => graph["label"].to_s.gsub(/:\d\d:\d\d .*/, "").gsub(" ", ", "), "value" => graph["value"].to_i, "collection_id" => graph["collection_id"], "graph_id" => graph["graph_id"]}
        else
          new_graphs[Time.parse(graph["label"].to_s.gsub(/:\d\d:\d\d .*/, "").gsub(" ", ", ")).to_i.to_s]["value"] += graph["value"].to_i
        end
      end
    when "day"
      graphs.each do |graph|
        if new_graphs[Time.parse(graph["label"].to_s.gsub(/\d\d:\d\d:\d\d( | -)\d\d\d\d/, "")).to_i.to_s].nil?
          new_graphs[Time.parse(graph["label"].to_s.gsub(/\d\d:\d\d:\d\d( | -)\d\d\d\d/, "")).to_i.to_s] = {"label" => graph["label"].to_s.gsub(/\d\d:\d\d:\d\d( | -)\d\d\d\d/, ""), "value" => graph["value"].to_i, "collection_id" => graph["collection_id"], "graph_id" => graph["graph_id"]}
        else
          new_graphs[Time.parse(graph["label"].to_s.gsub(/\d\d:\d\d:\d\d( | -)\d\d\d\d/, "")).to_i.to_s]["value"] += graph["value"].to_i
        end
      end
    end
    final_graphs = []
    new_graphs.keys.sort.each do |graph_key|
      final_graphs << new_graphs[graph_key]
    end
    return final_graphs
  end
end