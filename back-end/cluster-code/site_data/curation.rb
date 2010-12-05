class Curation < SiteData
  attr_accessor :id, :researcher_id, :created_at, :name, :updated_at, :datasets, :researcher, :single_dataset, :analyzed, :analysis_metadatas
  
  def researcher
    if @researcher.nil?
      @researcher = Researcher.find({:id => @researcher_id})
      return @researcher
    else
      return @researcher
    end
  end
  
  def datasets
    if @datasets.nil?
      @datasets = habtm(Dataset)
      return @datasets
    else
      return @datasets
    end
  end
  
  def habtm(class_name)
    query = "select #{class_name.underscore}.* from #{class_name.underscore} inner join curations_#{class_name.underscore} on #{class_name.underscore}.id = curations_#{class_name.underscore}.#{class_name.underscore.chop}_id where curations_#{class_name.underscore}.curation_id = #{@id}"
    temp_datasets = Database.result(query)
    temp_datasets.collect{|tm| tm.delete("#{class_name.underscore.chop}_id")}
    datasets = temp_datasets.collect{|tm| class_name.new(tm)}
    return datasets
  end
  
  def analysis_metadatas
    if @analysis_metadatas.nil?
      @analysis_metadatas = AnalysisMetadata.find_all({:curation_id => @id})
    else
      return @analysis_metadatas
    end
  end
  
  
  def folder_name
    "dataset_#{@id}"
  end
  
end