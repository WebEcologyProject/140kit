class AuthUsersController < ApplicationController
  layout "main"
  before_filter :admin_required
  
  def index(conditions={}, per_page=10, element_id='main')
    @page_title = "Twitter Accounts Management"
    if current_researcher.admin?
      model = params[:controller].classify.constantize
      if conditions.nil?
        value = (model.paginate :page => params[:page], :per_page => per_page)
      else
        value = (model.paginate :page => params[:page], :conditions => conditions, :per_page => per_page)
      end
      inst_var = instance_variable_set("@#{params[:controller]}", value)
      respond_to do |format|
        format.html
        format.xml  { render :xml => inst_var }
        format.js {
          render :update do |page|
            page.replace_html element_id, :partial => "#{params[:controller]}_index"
          end
        }
      end
    else 
      respond_to do |format|
        format.html { redirect_to "/"}
      end
    end
  end
  
end
