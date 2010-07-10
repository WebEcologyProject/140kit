class CollectionsController < ApplicationController
  layout "main"
  before_filter :login_required, :except => [:show, :index, :search]
  
  def index(conditions={}, per_page=10, element_id='main')
    super({:single_dataset => params[:single_dataset].to_bool, :order_by => "finished desc, analyzed desc, created_at desc"}, per_page, element_id)
  end
  
  # def index(conditions={}, per_page=10, element_id='main')
  #   sort = case params['sort']
  #          when "name" then "name"
  #          when "tweets"  then "tweets_count"
  #          when "users"   then "users_count"
  #          when "updated_at" then "created_at"
  #          when "name" then "name DESC"
  #          when "tweets"  then "tweets_count DESC"
  #          when "users"   then "users_count DESC"
  #          when "updated_at" then "created_at DESC"
  #          end
  #   @collections = Collection.paginate :order => sort, :conditions => conditions, :page => params[:page], :per_page => per_page
  #   if request.xml_http_request?
  #     render :partial => element_id, :layout => false
  #   end
  # end
  
  def show
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.find(params[:id]))
    @analytical_offerings = AnalyticalOffering.paginate :page => params[:page], :per_page => 10
    @current_researcher_id = current_researcher.id
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
    end
  end
  
  def create
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.new(params[params[:controller].singularize.to_sym]))
    respond_to do |format|
      if inst_var.save
        flash[:notice] = "#{model} was successfully created."
        format.html { redirect_to collection_url(inst_var.researcher.user_name, inst_var.id) }
        format.xml  { render :xml => inst_var, :status => :created, :location => inst_var }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => inst_var.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def manage
    index({:researcher_id => current_researcher.id})
  end
  
  def freeze
    @collection = Collection.find(params[:id])
    if @collection.scrape && !@collection.scrape.finished
      flash[:notice] = "Can't Freeze Dataset while still in process of collection"
    else
      @collection.finished = true
      @collection.save
    end
    redirect_to("/collections/#{params[:id]}")
  end
  
  def analytical_setup
    @collection = Collection.find(params[:id])
    @analytical_offerings = AnalyticalOffering.paginate :page => params[:page], :per_page => 10
  end
  
  def add_analytics
    @collection = Collection.find(params[:collection_id])
    @analytical_offering = AnalyticalOffering.find(params[:analytical_offering_id])
    @analysis_metadata = AnalysisMetadata.new
    @analysis_metadata.function = @analytical_offering.function
    @analysis_metadata.rest = @analytical_offering.rest
    @analysis_metadata.collection = @collection
    @analysis_metadata.save
    return unless request.xhr?
    render :update do |page|
      page.visual_effect :highlight, "analytical_offering_#{@analytical_offering.id}", :duration => 0.4
    end
  end
  
  def mothball
    @collection = Collection.find(params[:collection_id])
    @collection.mothballed = !@collection.mothballed
    @collection.save
    flash[:notice] = "Your collection has been successfully <a href=\"/pages/mothballing\">mothballed</a> for the time being"
    redirect_to("/collections")
  end
end
