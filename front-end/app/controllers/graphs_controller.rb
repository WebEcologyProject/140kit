class GraphsController < ApplicationController
  
  def show
    @chart_type, @chart_options = Graph.resolve_chart_settings(params[:title])    
    @collection_id = params[:collection_id]
    @style = params[:style]
    @title = params[:title]
    if request.xhr?
      render :update do |page|
        page.replace_html 'dataDisplay', :partial => "/graphs/graph", :locals => {
            :title => @title, 
            :style => @style, 
            :collection_id => @collection_id, 
            :chart_type => @chart_type,
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
