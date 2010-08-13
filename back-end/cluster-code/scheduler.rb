class Scheduler
  
  def self.rest(scrape_types)
    if $w.rest_allowed
      debugger
      metadatas = Scrape.find_all({:scrape_finished => false, :scrape_type => scrape_types}).collect{|scrape| scrape.metadatas}.flatten.compact
      unclaimed_metadatas = metadatas.select {|m| (m.instance_id.nil? || m.instance_id.empty?)}
      claimed_metadatas = metadatas.select {|m| (m.instance_id == $w.instance_id)}
      if claimed_metadatas.empty?
        metadata = unclaimed_metadatas.first
      else
        metadata = claimed_metadatas.first
      end
      if !metadata.nil?
        metadata.flagged = true
        metadata.instance_id = $w.instance_id
        metadata.save
        sleep(SLEEP_CONSTANT)
        refreshed_metadata = metadata.class.find(:id => metadata.id)
        if refreshed_metadata.instance_id == $w.instance_id
          $w.rest_instance.metadata = metadata
          return true
        end
      end
      return false
    else return false
    end
  end
  def self.stream(scrape_types)
    metadatas = Scrape.find_all({:scrape_finished => false, :scrape_type => scrape_types}).collect{|scrape| scrape.metadatas}.flatten.compact
    unclaimed_metadatas = metadatas.select {|m| (m.instance_id.nil? || m.instance_id.empty?)}
    claimed_metadatas = metadatas.select {|m| (m.instance_id == $w.instance_id)}
    return Scheduler.claim_metadata(unclaimed_metadatas, StreamInstance)
  end
  
  def self.claim_metadata(metadatas, instance_type)
    instances = instance_type.all
    end_selection = ((metadatas.length/instances.length)+1) >= metadatas.length ? metadatas.length/instances.length : (metadatas.length/instances.length)+1
    selected_bunch = metadatas[0..end_selection]
    if selected_bunch.length > 0
      Database.update_attributes(metadatas.first.class.sym, selected_bunch, {"flagged" => true, "instance_id" => $w.instance_id}) 
      sleep(SLEEP_CONSTANT)
      refreshed_bunch = selected_bunch.collect{|m| metadatas.first.class.find(:id => m.id)}
      if refreshed_bunch.first.instance_id == $w.instance_id
        $w.stream_instance.update_mix(refreshed_bunch)
        return true
      end
      return false
    else return false
    end
  end
  
  def self.decide_analysis_metadata
    metadata = AnalysisMetadata.find({:finished => false, :instance_id => $w.instance_id})
    return [metadata] if !metadata.nil?
    collections = Collection.find_all({:finished => true, :analyzed => false})
    result = Scheduler.analysis_metadata_from_collection(collections)
    return result if !result.empty?
    collections = Collection.find_all({:finished => true, :analyzed => true})
    result = Scheduler.analysis_metadata_from_collection(collections)
    return result if !result.empty?
    return [nil]
  end
  
  def self.analysis_metadata_from_collection(collections)
    collections.sort! {|a,b| a.created_at.to_i <=> b.created_at.to_i}
    for collection in collections
      if $w.rest_allowed
        metadatas = AnalysisMetadata.find_all({:collection_id => collection.id, :finished => false, :processing => false})
      else
        metadatas = AnalysisMetadata.find_all({:collection_id => collection.id, :finished => false, :processing => false, :rest => false})
      end
      if metadatas.length == 0
        finished_metadatas = AnalysisMetadata.find_all({:collection_id => collection.id, :finished => true})
        total_metadatas = AnalysisMetadata.find_all({:collection_id => collection.id})
        if finished_metadatas.length == AnalyticalOffering.count({:enabled => true}) && !collection.analyzed
          collection.analyzed = true
          collection.save
        end
      end
      for metadata in metadatas
        instance_id = Environment.db.query("select instance_id from analysis_metadatas where id = #{metadata.id}").fetch_hash
        instance_id = instance_id["instance_id"] if !instance_id.nil?
        if instance_id.class == NilClass || instance_id.empty?
          metadata.instance_id = $w.instance_id
          metadata.save
          sleep(SLEEP_CONSTANT)
          metadata = AnalysisMetadata.find({:id => metadata.id, :instance_id => $w.instance_id})
          return [metadata] if !metadata.nil?
        end
      end
    end
    return []
  end
end