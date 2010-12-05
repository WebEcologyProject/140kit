class ScrapesController < ApplicationController
  layout "main"
  before_filter :login_required, :except => [:show, :index, :search, :welcome, :track_submit, :track_preview]
  
  def new(element_id='main')
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.new)
    inst_var.run_ends = Time.now+10.minutes
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          page.replace_html element_id, :partial => "#{params[:controller]}_new", :locals => {:scrape_type => params[:scrape_type]}
        end
      }
    end
  end
  
  def create
    temp_params = params
    model = params[:controller].classify.constantize
    if !params[:scrape][:uploaded_data].nil?
      params = model.create_rest_temp_file(temp_params)
      inst_var = instance_variable_set("@#{params[:controller].singularize}", model.new(params[params[:controller].singularize.to_sym]))
    else
      inst_var = instance_variable_set("@#{temp_params[:controller].singularize}", model.new(temp_params[temp_params[:controller].singularize.to_sym]))
    end
    respond_to do |format|
      if inst_var.save
        @collection = inst_var.collection
        flash[:notice] = "#{model} was successfully created."
        format.html { redirect_to collection_url(inst_var.researcher.user_name, @collection.id) }
        format.xml  { render :xml => inst_var, :status => :created, :location => inst_var }
      else
        format.html { render :action => "new"}
        format.xml  { render :xml => inst_var.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end
