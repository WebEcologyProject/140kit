class GraphsController < ApplicationController

  def index
    @graphs = Graph.all
    respond_to do |format|
      format.xml  { render :xml => @graphs }
      format.json  { render :json => @graphs }
    end
  end

  def show
    @graph = Graph.find(params[:id])
    respond_to do |format|
      format.xml  { render :xml => @graph }
      format.json  { render :json => @graph }
    end
  end

  def api_query
    @graphs = interpret_request(params)
    respond_to do |format|
      format.xml  { render :xml => @graphs.to_xml }
      format.json  { render :json => @graphs.to_json }
    end    
  end

  def relational_query
    @graphs = super
    respond_to do |format|
      format.xml  { render :xml => @graphs.to_xml }
      format.json  { render :json => @graphs.to_json }
    end
  end
  
  def graph_query
    @graphs = super(params)
    respond_to do |format|
      format.xml  { render :xml => Graph.to_google_xml(@graphs) }
      format.json  { render :json => Graph.to_google_json(@graphs) }
    end    
  end
  
  def network_query
    logic_params = params[:logic].gsub(/[|:><]/, "_")
    @graphs = super(params)
    respond_to do |format|
      format.xml  { render :xml => Graph.to_graphml(@graphs, logic_params) }
      format.json  { render :json => Graph.to_rgraph_json(@graphs, logic_params) }
      format.graphml  { render :xml => Graph.to_graphml(@graphs, logic_params) }
    end    
  end
  
  def user_network_query
    @graphs = super(params)
    respond_to do |format|
      format.xml  { render :xml => Graph.to_graphml(@graphs) }
      format.json  { render :json => @graphs.to_json }
      format.graphml  { render :json => Graph.to_graphml(@graphs) }
    end    
  end
  

end
