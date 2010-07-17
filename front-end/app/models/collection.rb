class Collection < ActiveRecord::Base
  belongs_to :researcher
  has_many :analysis_metadatas
  has_many :collection_metadatas
  has_and_belongs_to_many :stream_metadatas
  has_and_belongs_to_many :rest_metadatas
  has_many :edges
  has_many :graphs
  has_many :graph_points
  before_create :fill_out_secondary_data
  has_one :stream_metadata
  has_one :rest_metadata
  belongs_to :scrape
  validates_presence_of :name
  
  def fill_out_secondary_data
    self.updated_at = Time.now
    self.created_at = Time.now
    self.folder_name = "#{self.name.downcase.gsub(".", "").gsub(" ", "_").gsub(/\W/, "")}-#{Time.now.strftime("%Y-%m-%d__%H:%M:%S")}"
  end
  
  def metadatas
    if self.scrape_method == "REST"
      metadatas = self.rest_metadatas
    elsif self.scrape_method == "Stream"
      metadatas = self.stream_metadatas
    elsif self.scrape_method == "Curate"
      metadatas = self.stream_metadatas+self.rest_metadatas
    else return []
    end
    return metadatas
  end

  def metadata
    if self.scrape_method == "REST"
      metadata = self.rest_metadata
    elsif self.scrape_method == "Stream"
      metadata = self.stream_metadata
    elsif self.scrape_method == "Curate"
      metadata = self.rest_metadata.nil? ? self.stream_metadata : self.rest_metadata
    else return nil
    end
    return metadata
  end
  
  def datasets
    return self.metadatas.collect{|m| m.class.find(m.id).collection}
  end
  
  def primary_collection
    return self.scrape.collection
  end
end