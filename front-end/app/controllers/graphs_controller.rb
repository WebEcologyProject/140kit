class GraphsController < ApplicationController

  def show
    @graph = Graph.find(params[:id])
    @chart_type, @chart_options = Graph.resolve_chart_settings(@graph.title)
    @graph_id = params[:id]
    @title = @graph.title
    if @graph.style == "time_based_histogram"
      @subtitle = @graph.month.nil? ? @graph.year : "#{@graph.month}, #{@graph.date} #{@graph.year}"
      if !@graph.hour.nil?
        @subtitle = @subtitle+", at #{@graph.hour} (UTC)"
      end
    else
      @subtitle = nil
    end
    if request.xhr?
      render :update do |page|
        page.replace_html 'dataDisplay', :partial => "/graphs/graph", :locals => {
            :title => @title, 
            :chart_type => @chart_type,
            :chart_options => @chart_options,
            :graph_id => @graph_id,
            :subtitle => @subtitle
        }
      end
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => inst_var }
      end
    end
  end
  
  def timeline
    @graphs = Graph.find(:all, :conditions => {:hour => params[:hour], :date => params[:date], :month => params[:month], :year => params[:year], :collection_id => params[:collection_id]})
    @collection_id = params[:collection_id]
    @style = params[:style]
    @chart_type = "timeline"
    @title = "Timeline: #{params[:year].nil? ? "" : params[:year]+":00,"} #{params[:month].nil? ? "" : number_to_month(params[:month])} #{params[:date].nil? ? "" : params[:date]+","} #{params[:year]}"
    if request.xhr?
      render :update do |page|
        page.replace_html 'dataDisplay', :partial => "/graphs/graph", :locals => {
            :graphs => @graphs,
            :title => @title, 
            :collection_id => @collection_id, 
            :chart_type => "timeline",
            :chart_options => @chart_options
        }
      end
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => inst_var }
      end
    end
  end
end
