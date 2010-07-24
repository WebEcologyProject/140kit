class AnalysisMetadata < ActiveRecord::Base
  belongs_to :collection
  has_one :instance, :class_name => "AnalyticalInstance", :primary_key => "instance_id", :foreign_key => "instance_id"
  
  def graphs(params={})
    case self.function
    when "basic_histograms"
      graphs = Graph.find(:all, :conditions => {:collection_id => self.collection_id, :style => "histogram", :hour => params[:hour], :date => params[:date], :month => params[:month], :year => params[:year]})
    when "word_frequency"
      graphs = Graph.find(:all, :conditions => {:collection_id => self.collection_id, :style => "word_frequency", :hour => params[:hour], :date => params[:date], :month => params[:month], :year => params[:year]})
    when "time_based_summary"
      graphs = Graph.find(:all, :conditions => {:collection_id => self.collection_id, :style => "time_based_histogram", :hour => params[:hour], :date => params[:date], :month => params[:month], :year => params[:year]})
    end
  end
  
  def gather_years
    year_graphs = Graph.find(:all, :conditions => {:collection_id => self.collection_id, :month => nil, :style => "time_based_histogram"})
    years = year_graphs.collect{|g| g.year}.uniq.sort
    return years
  end

  def gather_months(year)
    month_graphs = Graph.find(:all, :conditions => {:collection_id => self.collection_id, :year => year, :style => "time_based_histogram"})
    months = month_graphs.collect{|g| g.month if !g.month.nil?}.compact.uniq.sort
    return months
  end

  def gather_dates(year, month)
    date_graphs = Graph.find(:all, :conditions => {:collection_id => self.collection_id, :month => month, :year => year, :style => "time_based_histogram"})
    dates = date_graphs.collect{|g| g.date if !g.date.nil?}.compact.uniq.sort
    return dates
  end

  def gather_hours(year, month, date)
    hour_graphs = Graph.find(:all, :conditions => {:collection_id => self.collection_id, :date => date, :month => month, :year => year, :style => "time_based_histogram"})
    hours = hour_graphs.collect{|g| g.hour if !g.hour.nil?}.compact.uniq.sort
    return hours
  end
  
end
