class Scheduler
  
  def self.rest(scrape_types)
    if $w.rest_allowed
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
  
  def self.add_stream_datasets
    # datasets = Dataset.find_all({:scrape_finished => false, :scrape_type => ["Search", "Trend"]})
    datasets = Dataset.unlocked("scrape_finished = 0")
    return Scheduler.claim_new_stream_datasets(datasets)
  end
  
  def self.claim_new_stream_datasets(datasets) # for stream instances only right now
    # distribute datasets evenly
    return false if datasets.empty?
    num_instances = Instance.count({:instance_type => "stream", :killed => false})
    datasets_per_instance = (datasets.length.to_f / num_instances.to_f).ceil
    datasets_to_claim = datasets[0..datasets_per_instance]
    if !datasets_to_claim.empty?
      claimed_datasets = $w.lock_all(datasets_to_claim)
      if !claimed_datasets.empty?
        $w.stream_instance.update_datasets(claimed_datasets)
        return true
      end
    end
    return false
  end
  
  def self.decide_analysis_metadata
    params = {:finished => false}
    params[:rest] = false if $w.rest_allowed
    metadatas = AnalysisMetadata.find_all(params)
    
    for m_id in metadatas.collect {|m| m.id }.sort
      metadata = AnalysisMetadata.find({:id => m_id})
      return metadata if $w.lock(metadata)
    end
    return nil
  end
end