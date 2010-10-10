require 'digest/sha1'
class Researcher < ActiveRecord::Base
  has_many :curations
  has_many :collections
  has_many :scrapes
  has_many :news_items
  has_many :stream_metadatas
  has_many :comments, :foreign_key => 'post_id'
  has_one :image
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :user_name, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 6..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :user_name,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :user_name, :email, :case_sensitive => false
  before_save :encrypt_password
  before_save :set_times
  before_create :set_join_date
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(user_name, password)
    u = find_by_user_name(user_name) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def set_times
    self.last_login = Time.now
    self.last_access = Time.now
    self.remember_token_expires_at = 2.weeks.from_now.utc
  end
  
  def set_join_date
    self.join_date = Time.now
  end
  
  def validate_on_create
    if !self.user_name.scan(/[\.\;\:\?\<\>\,\+\=\_\-\{\}\[\]\(\)\|\\\*\&\^%\$#\@\!\~\`]/).empty?
      errors.add("User Name", "You can only use alpha numeric characters in your user name (a-z, 0-9).")
    end
  end
  
  def create_reset_code
    self.reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(false)
  end

  def delete_reset_code
    self.reset_code = nil
    save(false)
  end
  
  def admin?
    return self.role == "Admin"
  end
  
  protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user_name}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  def after_destroy 
    if Researcher.count.zero? 
      raise "Can't delete last researcher" 
    end 
  end
end
