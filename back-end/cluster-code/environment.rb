load "#{ROOT_FOLDER}cluster-code/utils/extensions.rb"

class Environment
  
  require "#{ROOT_FOLDER}cluster-code/database"
  require "#{ROOT_FOLDER}cluster-code/scheduler"
  require "#{ROOT_FOLDER}cluster-code/site_data"
  require "#{ROOT_FOLDER}cluster-code/worker"
  require "#{ROOT_FOLDER}cluster-code/utils/u"
  require "#{ROOT_FOLDER}cluster-code/utils/sql_parser"
  @@env = nil
  @@pro_db = nil
  @@test_db = nil
  @@dev_db = nil
  @@rest_db = nil
  @@stream_db = nil

  def self.read_from_config(runtime_environment, class_var=nil)
    
    settings = {}
    File.open("../config/#{runtime_environment}.txt", "r").read.split("\n").collect{|x| settings[x.split(":")[0]] = x.split(":")[1].nil? ? nil : x.split(":")[1].strip  }
    if !class_var.nil?
      class_variable_set(class_var, Mysql.real_connect(settings["hostname"], settings["user"], settings["password"], settings["database"]))
      @@db = eval(class_var.to_s)
      @@db.reconnect = true
      @@env = runtime_environment
    else return settings
    end
    puts "### #{runtime_environment.upcase} ENVIRONMENT ###"
  end
  
  def self.load(environment)
    case environment
    when "production"
      Environment.load_production
    when "testing"
      Environment.load_testing
    when "development"
      Environment.load_development
    end
  end
  
  def self.load_production
    Environment.read_from_config("production", :@@pro_db)
  end
  
  def self.load_testing
    settings = Environment.read_from_config("testing", :@@test_db)
  end
  
  def self.load_development
    settings = Environment.read_from_config("development", :@@dev_db)
  end

  def self.load_rest
    settings = Environment.read_from_config("rest", :@@rest_db)
  end
  
  def self.load_stream(stream_account)
    settings = Environment.read_from_config("stream_#{stream_account}", :@@stream_db)
  end
  
  def self.db
    return @@db
  end
  
  def self.pro_db
    return @@pro_db
  end
  
  def self.test_db
    return @@test_db
  end
    
  def self.dev_db
    return @@dev_db
  end
  
  def self.local_db
    return @@local_db
  end
  
  def self.pro_db
    return @@pro_db
  end
  
  def self.test_db
    return @@test_db
  end
  
  def self.rest_db
    return @@rest_db
  end
    
  def self.env
    return @@env
  end
  
  def self.set_db(db)
    @@db = db
  end
end