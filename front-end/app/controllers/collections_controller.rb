class CollectionsController < ApplicationController
  layout "main"
  before_filter :login_required, :except => [:show, :index, :search]
  
  def index(conditions={}, per_page=10, element_id='main')
    debugger
    @sort = params[:sort]
    if params[:single_dataset]
      if params[:sort]
        @page_title = params[:single_dataset].to_bool ? "All Datasets" : "All Collections"
        super({:single_dataset => params[:single_dataset].to_bool, :order_by => collection_sort(params[:sort])}, per_page, element_id)
      else
        @page_title = params[:single_dataset].to_bool ? "All Datasets" : "All Collections"
        super({:single_dataset => params[:single_dataset].to_bool, :order_by => "finished desc, tweets_count desc, created_at desc"}, per_page, element_id)
      end
    elsif params[:sort]
      @page_title = params[:single_dataset].to_bool ? "All Datasets" : "All Collections"
      super({:single_dataset => params[:single_dataset].to_bool, :order_by => collection_sort(params[:sort])}, per_page, element_id)
    else
      super(conditions, per_page, element_id)
    end
  end
  
  def collection_sort(sort)
    case sort
    when "name"
      return "name, created_at desc"
    when "name_desc"
      return "name desc, created_at desc"
    when "tweets"
      return "tweets_count, created_at desc"
    when "tweets_desc"
      return "tweets_count desc, created_at desc"
    when "users"
      return "users_count, created_at desc"
    when "users_desc"
      return "users_count desc, created_at desc"
    when "date_created"
      return "created_at desc"
    when "date_created_desc"
      return "created_at"
    end
  end
  
  def dataset_paginate
    @collection = Collection.find(params[:id])
    index({:id => @collection.datasets.collect{|d| d.id}}, 10, 'dataDisplay')
  end

  def show
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.find(params[:id]))
    @analytical_offerings = AnalyticalOffering.paginate :page => params[:page], :per_page => 10
    @current_researcher_id = current_researcher.id
    @page_title = "#{@collection.researcher.user_name}'s collections : #{@collection.name}"
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
    @page_title = "Collections Management"
    index({:researcher_id => current_researcher.id})
  end
  
  def creator
    @page_title = "Start a new collection"
  end
  
  def freeze
    @collection = Collection.find(params[:id])
    if @collection.scrape && !@collection.scrape.finished
      flash[:notice] = "Can't Freeze Dataset while still in process of collection"
    else
      if @collection.scrape_method == "Curate"
        @collection.tweets_count = @collection.datasets.collect{|t| t.tweets_count}.sum
        @collection.users_count = @collection.datasets.collect{|t| t.users_count}.sum
      end
      @collection.finished = true
      @collection.save
    end
    redirect_to("/collections/#{params[:id]}")
  end
  
  def alter
    @collection = Collection.find(params[:id])
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
    @analysis_metadata.save_path = @analytical_offering.save_path
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
    redirect_to(request.referrer)
  end
  
  def hide
    @collection = Collection.find(params[:collection_id])
    @collection.private_data = !@collection.private_data
    @collection.save
    flash[:notice] = "Your collection has been successfully <a href=\"/pages/hidden-datasets\">#{@collection.private_data ? "hidden" : "un-hidden"}</a> for the time being"
    redirect_to(request.referrer)
  end
  
  def rollback
    @collection = Collection.find(params[:collection_id])
    @collection.finished = false
    @collection.analyzed = false
    ActiveRecord::Base.connection.execute("delete from graphs where collection_id = #{@collection.id}")
    ActiveRecord::Base.connection.execute("delete from graph_points where collection_id = #{@collection.id}")
    ActiveRecord::Base.connection.execute("delete from analysis_metadatas where collection_id = #{@collection.id}")
    if @collection.scrape
      scrape = @collection.scrape
      scrape.finished = false
      if !@collection.single_dataset
        single_collections = Collection.find(:all, :conditions => {:scrape_id => scrape.id, :single_dataset => true})
        single_collections.each do |collection|
          ActiveRecord::Base.connection.execute("delete from graphs where collection_id = #{collection.id}")
          ActiveRecord::Base.connection.execute("delete from graph_points where collection_id = #{collection.id}")
          ActiveRecord::Base.connection.execute("delete from analysis_metadatas where collection_id = #{collection.id}")
          collection.finished = false
          collection.analyzed = false
          collection.save
        end
      end
      scrape.save
    end
    @collection.save
    flash[:notice] = "Your collection has been successfully <a href=\"/pages/rolling-back\">rolled back</a> for the time being"
    redirect_to(request.referrer)
  end
  
  def full_destroy
    @collection = Collection.find(params[:collection_id])
    ActiveRecord::Base.connection.execute("delete from graphs where collection_id = #{@collection.id}")
    ActiveRecord::Base.connection.execute("delete from graph_points where collection_id = #{@collection.id}")
    ActiveRecord::Base.connection.execute("delete from analysis_metadatas where collection_id = #{@collection.id}")
    ActiveRecord::Base.connection.execute("delete from stream_metadatas where collection_id = #{@collection.id}")
    ActiveRecord::Base.connection.execute("delete from rest_metadatas where collection_id = #{@collection.id}")
    if @collection.scrape
      scrape = @collection.scrape
      if !@collection.single_dataset
        single_collections = Collection.find(:all, :conditions => {:scrape_id => scrape.id, :single_dataset => true})
        single_collections.each do |collection|
          ActiveRecord::Base.connection.execute("delete from graphs where collection_id = #{collection.id}")
          ActiveRecord::Base.connection.execute("delete from graph_points where collection_id = #{collection.id}")
          ActiveRecord::Base.connection.execute("delete from analysis_metadatas where collection_id = #{collection.id}")
          ActiveRecord::Base.connection.execute("delete from stream_metadatas where collection_id = #{collection.id}")
          ActiveRecord::Base.connection.execute("delete from rest_metadatas where collection_id = #{collection.id}")
          collection.finished = false
          collection.analyzed = false
          collection.save
        end
      end
      scrape.save
    end
    @collection.destroy
    flash[:notice] = "This collection has been successfully destroyed."
    redirect_to(request.referrer)
  end
  
  def search
    per_page = 5
    @collection = Collection.find(params[:collection_id].to_s)
    @stream_metadatas = StreamMetadata.paginate :page => params[:page], :per_page => per_page, :conditions => "term like '%#{params[:query]}%' or sanitized_term like '%#{params[:query]}%'"
    @datasets = (@stream_metadatas.collect{|sm| sm.collection}-@collection.datasets).paginate :page => params[:addable_page], :per_page => per_page
    @removeable_datasets = @collection.datasets.paginate :page => params[:removeable_page], :per_page => per_page
    element_id = params[:element_id].to_s
    partial = params[:partial].to_s
    if request.xhr?
      respond_to do |format|
        format.js {
          render :update do |page|
            page.replace_html 'addableDatasets', :partial => "/datasets/datasets_associate"
          end
        }
      end
    end
  end
  
  def curate
    per_page = 5
    @collection = Collection.find(params[:id])
    final_statement = @collection.datasets.empty? ? "" :  "and id != #{@collection.datasets.collect{|d| d.id}.join(" and id != ")}"
    @addable_datasets = Collection.paginate :page => params[:addable_page], :per_page => per_page, :conditions => "finished = 1 and single_dataset = true and scrape_method != 'curate' #{final_statement} "
    @removeable_datasets = @collection.datasets.paginate :page => params[:removeable_page], :per_page => per_page
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html 'dataDisplay', :partial => "/datasets/datasets_curate"
        end
      }
    end
  end
  
  def associate
    per_page = 5
    @collection = Collection.find(params[:collection_id])
    @metadata = params[:metadata_type].constantize.find(params[:metadata_id])
    @collection.send(params[:metadata_type].underscore+"s=", @collection.send(params[:metadata_type].underscore+"s")<<@metadata)
    @collection.save
    final_statement = @collection.datasets.empty? ? "" :  "and id != #{@collection.datasets.collect{|d| d.id}.join(" and id != ")}"
    @addable_datasets = Collection.paginate :page => params[:addable_page], :per_page => per_page, :conditions => "finished = 1 and single_dataset = true and scrape_method != 'curate' #{final_statement} "
    @removeable_datasets = @collection.datasets.paginate :page => params[:removeable_page], :per_page => per_page
    return unless request.xhr?
    render :update do |page|
      page.replace_html 'dataDisplay', :partial => "/datasets/datasets_curate"
    end
  end
  
  def dissociate
    per_page = 5
    @collection = Collection.find(params[:collection_id])
    @metadata = params[:metadata_type].constantize.find(params[:metadata_id])
    @collection.send(params[:metadata_type].underscore+"s").delete(@metadata)
    @metadata.collections.delete(@collection)
    @collection.save
    @metadata.save
    final_statement = @collection.datasets.empty? ? "" :  "and id != #{@collection.datasets.collect{|d| d.id}.join(" and id != ")}"
    @addable_datasets = Collection.paginate :page => params[:addable_page], :per_page => per_page, :conditions => "finished = 1 and single_dataset = true and scrape_method != 'curate' #{final_statement} "
    @removeable_datasets = @collection.datasets.paginate :page => params[:removeable_page], :per_page => per_page
    return unless request.xhr?
    render :update do |page|
      page.replace_html 'dataDisplay', :partial => "/datasets/datasets_curate"
    end
  end
end