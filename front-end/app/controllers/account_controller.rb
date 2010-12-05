class AccountController < ApplicationController
  layout "main"
  include AuthenticatedSystem
  before_filter :login_from_cookie
  before_filter :login_required, :except => [:login, :signup, :forgot, :reset, :welcome]

  def login
    return unless request.post?
    self.current_researcher = Researcher.authenticate(params[:user_name], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_researcher.remember_me
        cookies[:auth_token] = { :value => self.current_researcher.remember_token , :expires => self.current_researcher.remember_token_expires_at }
      end
      
      redirect_to welcome_url
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    @researcher = Researcher.new(params[:researcher])
    return unless request.post?
    @researcher.save!
    self.current_researcher = @researcher
    redirect_to researcher_page_url(current_researcher.user_name)
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_researcher.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default("/")
  end
  
  def forgot
    @researcher = Researcher.find(:first, :conditions => {:user_name => params["login"]})
    if @researcher.nil?
      @researcher = Researcher.find(:first, :conditions => {:email => params["email"]})
    end
    @tweets = Tweet.find(:all, :limit => 10, :offset => rand(1000))
    if @researcher
      flash[:notice] = "An email containing a reset code has been sent."
      ResearcherNotifier.password_reset(@researcher)
      respond_to do |format|
        format.html
        format.xml  { render :xml => @tweets }
        format.js {
          render :update do |page|
            page.replace_html 'dataDisplay', :partial => "/tweets/tweets_index"
          end
        }
      end
    else
      flash[:notice] = "Sorry, we don't have anyone on file with that login."
      redirect_to("/login")
    end
  end
  
  def reset
    @researcher = Researcher.find_by_reset_code(params["reset_code"]) unless params["reset_code"].nil?
    if request.post?
      @researcher = Researcher.find_by_reset_code(params["researcher"]["reset_code"]) unless params["researcher"]["reset_code"].nil?
      if @researcher.update_attributes(:password => params["researcher"]["password"], :password_confirmation => params["researcher"]["password_confirmation"])
        self.current_researcher = @researcher
        @researcher.reset_code = nil
        @researcher.save
        flash[:notice] = "Password reset successfully for #{@researcher.email}"
        redirect_back_or_default('/')
      else
        flash[:notice] = "Sorry, there aren't any active reset codes that match #{params[:reset_code]}"
        redirect_to("/")
      end
    end
  end
  
end