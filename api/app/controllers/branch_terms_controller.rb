class BranchTermsController < ApplicationController

  def index
    @branch_terms = BranchTerm.all
    respond_to do |format|
      format.xml  { render :xml => @branch_terms }
      format.json  { render :json => @branch_terms }
    end
  end

  def show
    @branch_term = BranchTerm.find(params[:id])
    respond_to do |format|
      format.xml  { render :xml => @branch_term }
      format.json  { render :json => @branch_term }
    end
  end
  
  def api_query
    b = 0
    @branch_terms = interpret_request(params)
    respond_to do |format|
      format.xml  { render :xml => @branch_terms.to_xml }
      format.json  { render :json => @branch_terms.to_json }
    end    
  end

  def relational_query
    b = 0
    @branch_terms = super
    respond_to do |format|
      format.xml  { render :xml => @branch_terms.to_xml }
      format.json  { render :json => @branch_terms.to_json }
    end    
  end
  
end
