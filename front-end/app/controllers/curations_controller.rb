class CurationsController < ApplicationController

  layout "main"
  
  def destroy
    curation = Curation.find(params[:id])
    curation.analysis_metadatas.destroy_all
    curation.destroy
    respond_to do |format|
      format.html { redirect_to(welcome_url) }
      format.xml  { head :ok }
    end
  end
  
end