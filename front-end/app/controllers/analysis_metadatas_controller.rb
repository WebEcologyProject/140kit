class AnalysisMetadatasController < ApplicationController
  layout "main"
  def reveal_menu
    @am = AnalysisMetadata.find(:first, :conditions => {:function => "time_based_summary", :collection_id => params[:collection_id]})
    case params[:selection]
    when "months"
      @items = @am.gather_months(params[:year])
      @elem_id = "months"
    when "dates"
      @items = @am.gather_dates(params[:year], params[:month])
      @elem_id = "dates"
    when "hours"
      @items = @am.gather_hours(params[:year], params[:month], params[:date])
      @elem_id = "hours"
    end
    if request.xhr?
      render :update do |page|
        case @elem_id
        when "months"
          page.hide "dates"
          page.hide "hours"
          page.hide "finalMenu"
        when "dates"
          page.show "dates"
          page.hide "hours"
          page.hide "finalMenu"
        end
        page.replace_html @elem_id, :partial => "/analysis_metadatas/time_based_summary/menu", :locals => {
            :selection => params[:selection],
            :collection_id => params[:collection_id],
            :year => params[:year],
            :month => params[:month], 
            :date => params[:date],
            :items => @items
        }
      end
    end
  end
  
  def timeline_menu
    @graphs = Graph.find(:all, :conditions => {:collection_id => params[:collection_id], :hour => params[:hour], :date => params[:date], :month => params[:month], :year => params[:year]})
    if request.xhr?
      render :update do |page|
        page.show "finalMenu"
        page.replace_html 'finalMenu', :partial => "/analysis_metadatas/time_based_summary/final_menu", :locals => {
            :selection => params[:selection],
            :graphs => @graphs
        }
      end
    end
  end  
end
