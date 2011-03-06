class Curation < ActiveRecord::Base
  belongs_to :researcher
  has_and_belongs_to_many :datasets, :join_table => 'curation_datasets'
  has_many :analysis_metadatas
  has_many :graphs
  
  
  def tweets_count
    return self.datasets.collect {|d| d.tweets_count }.compact.sum
  end
  
  def users_count
    return self.datasets.collect {|d| d.users_count }.compact.sum
  end
  
  def status
    if analyzed?
      status = "Done"
    elsif datasets.all? {|d| d.scrape_finished }
      status = "Analyzing"
    else
      status = "Collecting"
    end
    return status
  end
  
  # def analyzed
  #   !self.datasets.collect {|d| d.analyzed }.include?(false)
  # end
  
  def scrape_finished
    !self.datasets.collect {|d| d.scrape_finished }.include?(false)
  end
  
  def end_time
    return nil if !self.datasets.select {|d| d.start_time.nil? || !["track", "follow", "location"].include?(d.scrape_type) || d.length.nil? }.empty?
    return self.datasets.collect {|d| d.start_time + d.length }.sort.last
  end
  
  def folder_name
    "dataset_#{id}"
  end
  
end
