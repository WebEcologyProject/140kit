class CollectionsController < ApplicationController
  # GET /collections
  # GET /collections.xml
  def index
    @collections = Collections.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collections }
    end
  end

  # GET /collections/1
  # GET /collections/1.xml
  def show
    @collections = Collections.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @collections }
    end
  end

  # GET /collections/new
  # GET /collections/new.xml
  def new
    @collections = Collections.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collections }
    end
  end

  # GET /collections/1/edit
  def edit
    @collections = Collections.find(params[:id])
  end

  # POST /collections
  # POST /collections.xml
  def create
    @collections = Collections.new(params[:collections])

    respond_to do |format|
      if @collections.save
        flash[:notice] = 'Collections was successfully created.'
        format.html { redirect_to(@collections) }
        format.xml  { render :xml => @collections, :status => :created, :location => @collections }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collections.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /collections/1
  # PUT /collections/1.xml
  def update
    @collections = Collections.find(params[:id])

    respond_to do |format|
      if @collections.update_attributes(params[:collections])
        flash[:notice] = 'Collections was successfully updated.'
        format.html { redirect_to(@collections) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collections.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.xml
  def destroy
    @collections = Collections.find(params[:id])
    @collections.destroy

    respond_to do |format|
      format.html { redirect_to(collections_url) }
      format.xml  { head :ok }
    end
  end
end
