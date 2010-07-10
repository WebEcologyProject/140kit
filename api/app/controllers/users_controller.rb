class UsersController < ApplicationController

  def index
    @users = User.all
    respond_to do |format|
      format.xml  { render :xml => @users }
      format.json  { render :json => @users }
    end
  end

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.xml  { render :xml => @user }
      format.json  { render :json => @user }
    end
  end

  def api_query
    b = 0
    @users = interpret_request(params)
    respond_to do |format|
      format.xml  { render :xml => @users.to_xml }
      format.json  { render :json => @users.to_json }
    end    
  end

  def relational_query
    b = 0
    @users = super
    respond_to do |format|
      format.xml  { render :xml => @users.to_xml }
      format.json  { render :json => @users.to_json }
    end    
  end

end
