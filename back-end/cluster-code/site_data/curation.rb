class Curation < SiteData
  attr_accessor :id, :researcher_id, :created_at, :name, :updated_at, :datasets, :researcher
  
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
  
end