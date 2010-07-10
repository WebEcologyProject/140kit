class TrendsController < ApplicationController

  def index
    @trends = Trend.all
    respond_to do |format|
      format.xml  { render :xml => @trends }
      format.json  { render :json => @trends }
    end
  end

  def show
    @trend = Trend.find(params[:id])
    respond_to do |format|
      format.xml  { render :xml => @trend }
      format.json  { render :json => @trend }
    end
  end

  def api_query
    b = 0
    @trends = interpret_request(params)
    respond_to do |format|
      format.xml  { render :xml => @trends.to_xml }
      format.json  { render :json => @trends.to_json }
    end    
  end

  def relational_query
    b = 0
    @trends = super
    respond_to do |format|
      format.xml  { render :xml => @trends.to_xml }
      format.json  { render :json => @trends.to_json }
    end    
  end

end
