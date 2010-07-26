class NewsController < ApplicationController
  layout "main"
  before_filter :login_from_cookie
  before_filter :admin_required, :except => [:show, :index]

  require "redcloth"
  
  def show
    if params[:slug] && params[:id]
      @news = News.find(params[:id])
    elsif params[:slug] && !params[:id]
      @news = News.find(:all, :conditions => {:slug => params[:slug]}).first
    elsif params[:id] && !params[:slug]
      @news = News.find(params[:id])
    end
    @page_title = @news.headline
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
    end
  end
  
  def index(conditions={}, per_page=10, element_id='main')
    @page_title = "News" if !@page_title
    model = params[:controller].classify.constantize
    if conditions.nil?
      value = (model.paginate :page => params[:page], :per_page => per_page)
    else
      value = (model.paginate :page => params[:page], :conditions => conditions, :order => "updated_at DESC", :per_page => per_page)
    end
    @news_items = value
    respond_to do |format|
      format.html
      format.xml  { render :xml => inst_var }
      format.js {
        render :update do |page|
          page.replace_html element_id, :partial => "#{params[:controller]}_index"
        end
      }
    end
  end

  def manage
    @page_title = "News/Page Management"
    index
  end

  def create
    model = params[:controller].classify.constantize
    inst_var = instance_variable_set("@#{params[:controller].singularize}", model.new(params[params[:controller].singularize.to_sym]))
    respond_to do |format|
      if inst_var.save
        flash[:notice] = "#{model} was successfully created."
        format.html { redirect_to("/news") }
        format.xml  { render :xml => inst_var, :status => :created, :location => inst_var }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => inst_var.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end