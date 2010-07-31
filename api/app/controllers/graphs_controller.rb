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

  def google_graph_query
    @graph = Graph.find(params[:id])
    respond_to do |format|
      format.xml  { render :xml => Graph.to_google_xml(@graph, params) }
      format.json  { render :json => Graph.to_google_json(@graph, params) }
    end    
  end
  
  def graph_query
    original_params = params.dup
    @graphs = super(params)
    respond_to do |format|
      format.xml  { render :xml => Graph.to_google_xml(@graphs, original_params) }
      format.json  { render :json => Graph.to_google_json(@graphs, original_params) }
    end    
  end
  
  def network_query
    original_params = params.dup
    results = super(params)
    respond_to do |format|
      format.xml  { render :xml => results }
      format.json  { render :json => results }
      format.graphml  { render :xml => results }
    end    
  end
  
  def user_network_query
    original_params = params.dup
    @graphs = super(params)
    respond_to do |format|
      format.xml  { render :xml => Graph.to_graphml(@graphs, original_params) }
      format.json  { render :json => @graphs.to_json }
      format.graphml  { render :json => Graph.to_graphml(@graphs, original_params) }
    end    
  end
  

end
