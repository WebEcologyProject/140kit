class ScrapesController < ApplicationController

  def index
    @scrapes = Scrape.all
    respond_to do |format|
      format.xml  { render :xml => @scrapes }
      format.json  { render :json => @scrapes }
    end
  end

  def show
    @scrape = Scrape.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scrape }
      format.json  { render :json => @scrape }
    end
  end
  
  def api_query
    b = 0
    @scrapes = interpret_request(params)
    respond_to do |format|
      format.xml  { render :xml => @scrapes.to_xml }
      format.json  { render :json => @scrapes.to_json }
    end    
  end

  def relational_query
    b = 0
    @scrapes = super
    respond_to do |format|
      format.xml  { render :xml => @scrapes.to_xml }
      format.json  { render :json => @scrapes.to_json }
    end    
  end
  
end
