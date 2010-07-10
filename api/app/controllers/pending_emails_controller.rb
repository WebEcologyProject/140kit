class PendingEmailsController < ApplicationController
  # GET /pending_emails
  # GET /pending_emails.xml
  def index
    @pending_emails = PendingEmail.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pending_emails }
    end
  end

  # GET /pending_emails/1
  # GET /pending_emails/1.xml
  def show
    @pending_email = PendingEmail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pending_email }
    end
  end

  # GET /pending_emails/new
  # GET /pending_emails/new.xml
  def new
    @pending_email = PendingEmail.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pending_email }
    end
  end

  # GET /pending_emails/1/edit
  def edit
    @pending_email = PendingEmail.find(params[:id])
  end

  # POST /pending_emails
  # POST /pending_emails.xml
  def create
    @pending_email = PendingEmail.new(params[:pending_email])

    respond_to do |format|
      if @pending_email.save
        flash[:notice] = 'PendingEmail was successfully created.'
        format.html { redirect_to(@pending_email) }
        format.xml  { render :xml => @pending_email, :status => :created, :location => @pending_email }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pending_email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pending_emails/1
  # PUT /pending_emails/1.xml
  def update
    @pending_email = PendingEmail.find(params[:id])

    respond_to do |format|
      if @pending_email.update_attributes(params[:pending_email])
        flash[:notice] = 'PendingEmail was successfully updated.'
        format.html { redirect_to(@pending_email) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pending_email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pending_emails/1
  # DELETE /pending_emails/1.xml
  def destroy
    @pending_email = PendingEmail.find(params[:id])
    @pending_email.destroy

    respond_to do |format|
      format.html { redirect_to(pending_emails_url) }
      format.xml  { head :ok }
    end
  end
end
