class GraphPointsController < ApplicationController

  def index
    @graph_points = GraphPoint.all
    respond_to do |format|
      format.xml  { render :xml => @graph_points }
      format.json  { render :json => @graph_points }
    end
  end

  def show
    @graph_point = GraphPoint.find(params[:id])
    respond_to do |format|
      format.xml  { render :xml => @graph_point }
      format.json  { render :json => @graph_point }
    end
  end

  def api_query
    b = 0
    @graph_points = interpret_request(params)
    respond_to do |format|
      format.xml  { render :xml => @graph_points.to_xml }
      format.json  { render :json => @graph_points.to_json }
    end    
  end

  def relational_query
    b = 0
    @graph_points = super
    respond_to do |format|
      format.xml  { render :xml => @graph_points.to_xml }
      format.json  { render :json => @graph_points.to_json }
    end    
  end

end
