class ResearchersController < ApplicationController
  layout "main"

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
    if !params[params[:controller].singularize][:password].empty? && params[params[:controller].singularize][:password] == params[params[:controller].singularize][:password_confirmation]
      if params[params[:controller].singularize][:password].length >= 6
        inst_var.password = params[params[:controller].singularize][:password]
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
    @collections = Collection.paginate :page => params[:page], :conditions => {:researcher_id => @researcher.id, :single_dataset => false}, :per_page => 10
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
    index
  end
end
