class Dataset < SiteData
  attr_accessor :id, :created_at, :term, :updated_at, :start_time, :length, :scrape_type, :scrape_finished, :instance_id
  attr_accessor :curations, :tweets, :users, :analysis_metadatas, :analyzed, :tweets_count, :users_count
  
  
  def tweets
    if @tweets.nil?
      @tweets = Tweet.find_all({:dataset_id => @id})
    else
      return @tweets
    end
  end
  
  def users
    if @users.nil?
      @users = User.find_all({:dataset_id => @id})
    else
      return @users
    end
  end
  
  def analysis_metadatas
    if @analysis_metadatas.nil?
      @analysis_metadatas = AnalysisMetadata.find_all({:dataset_id => @id})
    else
      return @analysis_metadatas
    end
  end
  
  def curations
    if @curations.nil?
      @curations = habtm(Curation, Dataset, "curations_datasets")
      return @curations
    else
      return @curations
    end
  end
  
  def folder_name
    "dataset_#{@id}"
  end
  
  def habtm(class_to_return, associated_class, relation_table_name)
    query = "select #{class_to_return.underscore}.* from #{class_to_return.underscore} "
    query += "inner join #{relation_table_name} "
    query += "on #{class_to_return.underscore}.id = #{relation_table_name}.#{class_to_return.underscore.chop}_id "
    query += "where #{relation_table_name}.#{associated_class.underscore.chop}_id = #{@id}"
    temp_objs = Database.result(query)
    temp_objs.collect{|tm| tm.delete("#{class_to_return.underscore.chop}_id")}
    objs = temp_objs.collect{|tm| class_to_return.new(tm)}
    return objs
  end
  
end