class CommentsController < ApplicationController
  layout "main"
  before_filter :admin_required, :except => [:new, :create]
  def index
    @page_title = "Tickets Management"
    super
  end

  def show
    super
    @page_title = "Ticket ##{@comment.id}"
  end

  
  def new(element_id='main')
    @page_title = "submit a ticket"
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.new)
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          page.replace_html element_id, :partial => "#{params[:controller]}_new"
        end
      }
    end
  end

  def create
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.new(params[params[:controller].singularize.to_sym]))
    respond_to do |format|
      if inst_var.save
        flash[:notice] = "Thanks for the ticket, yo. We'll get right on it and let you know how it goes."
        format.html { redirect_to("/") }
        format.xml  { render :xml => inst_var, :status => :created, :location => inst_var }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => inst_var.errors, :status => :unprocessable_entity }
      end
    end
  end

end
