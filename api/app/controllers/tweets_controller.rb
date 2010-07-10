class TweetsController < ApplicationController

  def index
    @tweets = Tweet.all
    respond_to do |format|
      format.xml  { render :xml => @tweets }
      format.json  { render :json => @tweets }
    end
  end

  def show
    @tweet = Tweet.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @tweet }
      format.json  { render :json => @tweet }
    end
  end
  
  def api_query
    b = 0
    @tweets = interpret_request(params)
    respond_to do |format|
      format.xml  { render :xml => @tweets.to_xml }
      format.json  { render :json => @tweets.to_json }
    end    
  end

  def relational_query
    b = 0
    @tweets = super
    respond_to do |format|
      format.xml  { render :xml => @tweets.to_xml }
      format.json  { render :json => @tweets.to_json }
    end    
  end
end
