class StreamMetadatasController < ApplicationController
  
  def collection_paginate
    @collection = Collection.find(params[:id])
    sm_ids = @collection.stream_metadata_ids
    index({:id => sm_ids}, 10, 'dataDisplay')
  end
  
  def index(conditions={}, per_page=10, element_id='main')
    if params[:id].nil?
      psmid = params[:previous_sm_id].nil? ? 0 : params[:previous_sm_id]
      prmid = params[:previous_rm_id].nil? ? 0 : params[:previous_rm_id]
      sm = StreamMetadata.find(:all, :conditions => "term != 'retweet' and scrape_id != 0 and id > #{psmid}", :order => "id asc", :limit => per_page, :offset => params[:addable_page])
      rm = RestMetadata.find(:all, :conditions => "scrape_id != 0 and id > #{prmid}", :order => "id asc", :limit => per_page, :offset => params[:addable_page])
      @addable_metadatas = (sm+rm).paginate :page => params[:addable_page], :per_page => per_page
    else
      @collection = Collection.find(params[:id])
      @metadatas = @collection.metadatas.paginate :page => params[:page], :per_page => per_page
    end
    respond_to do |format|
      format.html {render "/metadatas/index", :layout => 'main'}
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          page.replace_html element_id, :partial => "/metadatas/metadatas_index"
        end
      }
    end
  end

  def curate
    per_page = 5
    @collection = Collection.find(params[:id])
    @addable_stream_datasets = Collection.find(:all, :conditions => {:finished => true, :single_dataset => true, :scrape_method => "Stream"})#, :conditions => "term != 'retweet' and scrape_id != 0"
    @addable_rest_datasets = Collection.find(:all, :conditions => {:finished => true, :single_dataset => true, :scrape_method => "REST"})#, :conditions => "scrape_id != 0"
    @removeable_datasets = @collection.datasets.paginate :page => params[:removeable_page], :per_page => per_page
    @addable_stream_datasets = (@addable_stream_datasets-@removeable_datasets).select{|d| !d.metadata.nil?}
    @addable_rest_datasets = (@addable_rest_datasets-@removeable_datasets).select{|d| !d.metadata.nil?}
    @addable_stream_datasets = @addable_stream_datasets.paginate :page => params[:addable_stream_page], :per_page => per_page
    @addable_rest_datasets = @addable_rest_datasets.paginate :page => params[:addable_rest_page], :per_page => per_page
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html 'dataDisplay', :partial => "/datasets/datasets_curate"
        end
      }
    end
  end

  def remove
    @collection = Collection.find(params[:id])
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          page.replace_html 'main', :partial => "metadatas_associate"
        end
      }
    end
  end
  
  def associate
    @collection = Collection.find(params[:collection_id])
    case params[:metadata_type]
    when "StreamMetadata"
      @metadata = StreamMetadata.find(params[:metadata_id])
      @collection.stream_metadatas << @metadata
    when "RestMetadata"
      @metadata = RestMetadata.find(params[:metadata_id])
      @collection.rest_metadatas << @metadata
    end
    @collection.save
    @removeable_metadatas = @collection.metadatas.paginate :page => params[:removeable_page], :per_page => 5
    return unless request.xhr?
    render :update do |page|
      page.replace "unfrozenCollectionMenu", :partial => "collections/unfrozen_collection_menu"
      page.visual_effect :fade, "addable_metadata_#{@metadata.id}", :duration => 0.4
      page.replace_html "removeableMetadatas", :partial => "/metadatas/metadatas_associate", :locals => {:collection => @collection, :metadatas => @removeable_metadatas, :page_param => "removeable_page", :id_prefix => "removeable"}
    end
  end
  
  def dissociate
    @collection = Collection.find(params[:collection_id])
    case params[:metadata_type]
    when "StreamMetadata"
      @metadata = StreamMetadata.find(params[:metadata_id])
      @collection.stream_metadatas.delete(@metadata)
    when "RestMetadata"
      @metadata = RestMetadata.find(params[:metadata_id])
      @collection.rest_metadatas.delete(@metadata)
    end
    @metadata.collections.delete(@collection)
    @collection.save
    @metadata.save
    @removeable_metadatas = @collection.metadatas.paginate :page => params[:removeable_page], :per_page => 5
    return unless request.xhr?
    render :update do |page|
      page.replace "unfrozenCollectionMenu", :partial => "collections/unfrozen_collection_menu"
      page.visual_effect :fade, "removeable_metadata_#{@metadata.id}", :duration => 0.4
      page.replace "addable_#{@metadata.class.to_s.underscore}_#{@metadata.id}_associate_button", :partial => "metadatas/associate_button", :locals => {:metadata => @metadata, :collection => @collection, :id_prefix => "addable"}
    end
  end
  
  def show
    @metadata = params[:metadata_type].classify.constantize.find(params[:metadata_id])
    respond_to do |format|
      format.html {render "/metadatas/show", :layout => 'main'}
      format.xml  { render :xml => inst_var }
    end
  end
end