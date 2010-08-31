class Collection < SiteData
  attr_accessor :id, :researcher_id, :created_at, :name, :updated_at, :scrape_id, :metadata, :scrape_method
  attr_accessor :updated_at, :finished, :analyzed, :notified, :folder_name, :instance_id, :flagged, :single_dataset, :private_data
  attr_accessor :metadatas, :pending_email, :edges, :graph_points, :scraped_collection, :tweets_count, :users_count, :mothballed
  attr_accessor :graphs, :analysis_metadatas, :researcher, :scrape


  ###############Relation methods
  def metadatas
    if @metadatas.nil?
      if @scrape_method == "Stream"
        @metadatas = self.habtm(StreamMetadata)
      elsif @scrape_method == "REST"
        @metadatas = self.habtm(RestMetadata)
      elsif @scrape_method == "Curate"
        stream_metadatas = self.habtm(StreamMetadata)
        rest_metadatas = self.habtm(RestMetadata)
        @metadatas = stream_metadatas+rest_metadatas
      elsif @metdata.nil?
        return []
      else
        return []
      end
      return @metadatas
    else
      return @metadatas
    end
  end

  def habtm(class_name)
    query = "select #{class_name.underscore}.* from #{class_name.underscore} inner join collections_#{class_name.underscore} on #{class_name.underscore}.id = collections_#{class_name.underscore}.#{class_name.underscore.chop}_id where collections_#{class_name.underscore}.collection_id = #{@id}"
    temp_metadatas = Database.result(query)
    temp_metadatas.collect{|tm| tm.delete("#{class_name.underscore.chop}_id")}
    metadatas = temp_metadatas.collect{|tm| class_name.new(tm)}
    return metadatas
  end

  def metadata
    if self.single_dataset
      if @metadata.nil?
        if @scrape_method == "Stream"
          @metadata = StreamMetadata.find({:collection_id => @id})
        elsif @scrape_method == "REST"
          @metadata = RestMetadata.find({:collection_id => @id})
        else return nil
        end
      else
        return @metadata
      end
    else
      return nil
    end
  end
  
  def analysis_metadatas
    if @analysis_metadatas.nil?
      @analysis_metadatas = AnalysisMetadata.find_all({:collection_id => @id})
      return @analysis_metadatas
    else
      return @analysis_metadatas
    end
  end

  def pending_email
    if @pending_email.nil?
      @pending_email = PendingEmail.find_all({:collection_id => @id})
    else
      return @pending_email
    end
  end

  def edges
    if @edges.nil?
      @edges = Edge.find_all({:collection_id => @id})
    else
      return @edges
    end
  end

  def graph_points
    if @graph_points.nil?
      @graph_points = GraphPoint.find_all({:collection_id => @id})
    else
      return @graph_points
    end
  end

  def graphs
    if @graphs.nil?
      @graphs = Graph.find_all({:collection_id => @id})
    else
      return @graphs
    end
  end

  def analysis_metadata
    if @analysis_metadata.nil?
      @analysis_metadata = AnalysisMetadata.find_all({:collection_id => @id})
    else
      return @analysis_metadata
    end
  end

  def researcher
    if @researcher.nil?
      @researcher = Researcher.find({:id => @researcher_id})
    else
      return @researcher
    end
  end
  
  def scrape
    if @scrape.nil?
      @scrape = Scrape.find({:id => @scrape_id})
    else
      return @scrape
    end
  end

end