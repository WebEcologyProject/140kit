class StreamMetadatasController < ApplicationController
    
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
    
  def show
    @metadata = params[:metadata_type].classify.constantize.find(params[:metadata_id])
    respond_to do |format|
      format.html {render "/metadatas/show", :layout => 'main'}
      format.xml  { render :xml => inst_var }
    end
  end
end