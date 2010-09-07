class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  include AuthenticatedSystem
  layout "main"
  before_filter :login_required, :except => [:show, :index, :search, :welcome]

  def search
    @collection = Collection.find(params[:collection_id].to_s) if params[:collection_id]
    model = params[:model].class == Array ? params[:model].first : params[:model].first.first
  	query = params[:query] != 'Search' ? params[:query] : ''
  	partial = params[:partial].nil? ? '/layouts/search_results' : params[:partial].first.first
  	element_id = params[:element_id].nil? ? 'dataDisplay' : params[:element_id].first.first
    pre_conditions = USQL.resolve_pre_existing_conditions(params[:conditions].keys)
    conditions = USQL.resolve_query(model, query, pre_conditions)
    @items = model.constantize.paginate :page => params[:page], :conditions => conditions, :per_page => 10
    if request.xhr?
      respond_to do |format|
        format.js {
          render :update do |page|
            page.replace_html element_id, :partial => partial, :locals => {:display_user_header => true}
          end
        }
      end
    end
  end

  #DEFAULT RAILS ACTIONS
  def index(conditions={}, per_page=10, element_id='main')
    model = params[:controller].classify.constantize
    if conditions.nil?
      value = (model.paginate :page => params[:page], :per_page => per_page)
    else
      if conditions[:order_by]
        order_by = conditions.delete(:order_by)
        value = (model.paginate :page => params[:page], :conditions => conditions, :order => order_by, :per_page => per_page)
      else
        value = (model.paginate :page => params[:page], :conditions => conditions, :per_page => per_page)
      end
    end
    inst_var = instance_variable_set("@#{params[:controller]}", value)
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          page.replace_html element_id, :partial => "#{params[:controller]}_index"
        end
      }
    end
  end

  def show
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.find(params[:id]))
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
    end
  end
  
  def welcome
    @page_title = "The Free, Open Source Twitter Analytics Platform"
    @news = News.find_by_slug("welcome-to-140kit")
  end
  
  def new(element_id='main')
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.new)
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          page.replace_html element_id, :partial => "#{params[:controller]}_new"
        end
      }
    end
  end

  def edit
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.find(params[:id]))
  end

  def create
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.new(params[params[:controller].singularize.to_sym]))
    respond_to do |format|
      if inst_var.save
        flash[:notice] = "#{model} was successfully created."
        format.html { redirect_to(inst_var) }
        format.xml  { render :xml => inst_var, :status => :created, :location => inst_var }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => inst_var.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.find(params[:id]))
    respond_to do |format|
      if inst_var.update_attributes(params[params[:controller].singularize.to_sym])
        flash[:notice] =  "#{model} was successfully updated."
        format.html { redirect_to(request.referrer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => inst_var.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller]}", model.find(params[:id]))
    inst_var.destroy
    respond_to do |format|
      format.html { redirect_to("/#{params[:controller]}") }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def admin_required
    if !logged_in? || (logged_in? && !current_researcher.admin?)
      redirect_to root_url
    end
  end
  
end