class AnalyticalOfferingsController < ApplicationController
  before_filter :admin_required, :except => [:index, :curate]
  
  layout "main"
  def curate
    @collection = Collection.find(params[:id])
    @analytical_offerings = AnalyticalOffering.paginate :page => params[:page], :per_page => 2
    @added_functions = @collection.analysis_metadatas.collect{|am| am.function}
    # addable_condition = @collection.analysis_metadatas.collect{|am| " function != '#{am.function}' "}.join(" and ")
    # removeable_condition = @collection.analysis_metadatas.collect{|am| " function = '#{am.function}' "}.join(" or ")
    # @addable_analytical_offerings = AnalyticalOffering.paginate :page => params[:page], :conditions => addable_condition, :per_page => 10
    # @removeable_analytical_offerings = removeable_condition.blank? ? [] : AnalyticalOffering.paginate(:page => params[:page], :conditions => removeable_condition, :per_page => 10)
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          page.replace_html 'dataDisplay', :partial => "analytical_offerings_curate"
        end
      }
    end
  end
  
  def manage
    @page_title = "Analytical Offerings Management"
    @analytical_offerings = AnalyticalOffering.paginate :page => params[:page], :per_page => 10
  end
  
  def enable
    @analytical_offering = AnalyticalOffering.find(params[:id])
    @analytical_offering.enabled = !@analytical_offering.enabled
    @analytical_offering.save
    redirect_to(:back)
  end
end
