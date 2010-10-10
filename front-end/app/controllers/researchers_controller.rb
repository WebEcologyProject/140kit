class ResearchersController < ApplicationController
  
  before_filter :admin_required, :only => [:promote, :suspend, :manage]
  
  layout "main"
  
  def index
    @page_title = "All Researchers"
    super
  end
  
  def edit
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.find(params[:id]))
    @page_title = "Edit Profile"
    if !current_researcher.admin? || (current_researcher.id != @researcher.id)
      redirect_to("/pages/nasty-boys")
    end
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
    debugger
    if params[params[:controller].singularize][:password]
      if !params[params[:controller].singularize][:password].empty? && params[params[:controller].singularize][:password] == params[params[:controller].singularize][:password_confirmation]
        if params[params[:controller].singularize][:password].length >= 6
          inst_var.password = params[params[:controller].singularize][:password]
        end
      end
    end
    respond_to do |format|
      if inst_var.update_attributes(params[params[:controller].singularize.to_sym])
        flash[:notice] =  "#{model} was successfully updated."
        format.html { redirect_to("/#{inst_var.user_name}") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => inst_var.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @researcher = Researcher.find_by_user_name(params[:user_name])
    @page_title = "#{@researcher.user_name}'s page"
    @finished_collections = Collection.paginate :page => params[:finished_page] || 1, :conditions => {:researcher_id => @researcher.id, :single_dataset => false, :finished => true}, :per_page => 10
    @unfinished_collections = Collection.paginate :page => params[:unfinished_page] || 1, :conditions => {:researcher_id => @researcher.id, :single_dataset => false, :finished => false}, :per_page => 10
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          debugger
          js_collections, page_param = params[:update_div].include?("unfinished") ? [@unfinished_collections,"unfinished_page"] : [@finished_collections,"finished_page"]
          page.replace_html params[:update_div], :partial => "/collections/collections_index", :locals => {:collections => js_collections, :update_div => params[:update_div], :page_param => page_param}
        end
      }
    end
  end

  def promote
    @researcher = Researcher.find(params[:id])
    case @researcher.role
    when "User"
      @researcher.role = "Admin"
    end
    @researcher.save
  end

  def suspend
    @researcher = Researcher.find(params[:id])
    @researcher.suspended = !@researcher.suspended
    @researcher.save
  end
  
  def manage
    @page_title = "Researcher Management"
    model = params[:controller].classify.constantize
    value = (model.paginate :page => params[:page], :per_page => 10)
    inst_var = instance_variable_set("@#{params[:controller]}", value)
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          page.replace_html 'main', :partial => "researcher_manage_index"
        end
      }
    end
  end
  
  def access_level
    @researcher = Researcher.find(params[:id])
  end
end
