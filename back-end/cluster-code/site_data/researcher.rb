class Researcher < SiteData
  attr_accessor :user_name, :email, :created_at, :updated_at, :suspended, :share_email, :private_data, :hidden_account
  attr_accessor :remember_token, :remember_token_expires_at, :password_reset_code, :id, :salt, :crypted_password
  attr_accessor :last_login, :join_date, :last_access, :info, :website_url, :location, :pass_hash, :role, :reset_code
  attr_accessor :scrapes, :collections, :curations
  ###############Relation methods

  def scrapes
    if @scrapes.nil?
      @scrapes = Scrape.find_all({:researcher_id => @id})
      return @scrapes
    else
      return @scrapes
    end
  end

  def collections
    if @collections.nil?
      @collections = Collection.find_all({:researcher_id => @id})
      return @collections
    else
      return @collections
    end
  end
  
  def curations
    if @curations.nil?
      @curations = Curation.find_all({:researcher_id => @id})
      return @curations
    else
      return @curations
    end
  end

end
