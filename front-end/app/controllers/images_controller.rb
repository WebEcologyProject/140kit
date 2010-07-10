class ImagesController < ApplicationController
  layout "main"

  def create
    @image = Image.new(params[:image])
    respond_to do |format|
      if @image.save
        flash[:notice] = 'Image was successfully created.'
        format.html { redirect_to :controller => 'researchers', :action => 'edit', :id => @image.researcher_id}
        format.xml  { render :xml => @image, :status => :created, :location => @image }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @image = Image.find(params[:id])
    respond_to do |format|
      if @image.update_attributes(params[:image])
        flash[:notice] = 'Image was successfully updated.'
        format.html { redirect_to :controller => 'researchers', :action => 'edit', :id => @image.researcher_id}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    respond_to do |format|
      format.xml  { head :ok }
      format.js do
        render :update do |page|
          page.visual_effect :Fade, "image_#{@image.id}", :duration => 0.4
        end
      end
    end
  end
end
