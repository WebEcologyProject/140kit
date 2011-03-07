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
  @@storage_type = nil
  @@storage_path = nil
  @@storage_ssh = nil

  def self.read_from_config(runtime_environment, class_var=nil)
    settings = U.get_config[runtime_environment]
    if !class_var.nil?
      class_variable_set(class_var, Mysql.real_connect(settings["host"], settings["username"], settings["password"], settings["database"]))
      @@db = eval(class_var.to_s)
      @@db.reconnect = true
      @@env = runtime_environment
      @@host = settings["host"]
      @@password = settings["password"]
      @@username = settings["username"]
      @@database = settings["database"]
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
    Environment.setup_file_storage
    Environment.setup_tk_authentication
  end
  
  def self.load_production
    Environment.read_from_config("production", :@@pro_db)
  end
  
  def self.load_test
    settings = Environment.read_from_config("test", :@@test_db)
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
  
  def self.host
    return @@host
  end
  
  def self.username
    return @@username
  end
  
  def self.password
    return @@password
  end
  
  def self.database
    return @@database
  end
  
  def self.storage_type
    return @@storage_type
  end
  
  def self.storage_path
    return @@storage_path
  end
  
  def self.storage_ssh
    return @@storage_ssh
  end

  def self.tk_username
    return @@tk_username
  end

  def self.tk_password
    return @@tk_password
  end
  
  def self.set_db(db)
    @@db = db
  end
  
  def self.new_db_connect
    settings = U.get_config[$runtime_environment]
    return Mysql.real_connect(settings["host"], settings["username"], settings["password"], settings["database"])
  end
  
  def self.load_arguments
    database = nil
    storage_location = nil
    run_type = ARGV.shift
    if ARGV.include?("-db")
      database = ARGV[ARGV.index("-db")+1]
    elsif ARGV.include?("--database")
      database = ARGV[ARGV.index("--database")+1]
    end
    if ARGV.include?("-sl")
      storage_location = ARGV[ARGV.index("-sl")+1]  
    elsif ARGV.include?("--storage-location")
      storage_location = ARGV[ARGV.index("--storage-location")+1]
    end  
    database = database.nil? ? ENVIRONMENT : database
    storage_location = storage_location.nil? ? "local" : storage_location
    $runtime_environment = database
    return run_type,database,storage_location
  end
  
  def self.setup_file_storage
    settings = U.get_config["file_storage"]
    if settings.nil?
      @@storage_type = "local"
      @@storage_path = "front_end/public/files"
    else
      settings.each_pair do |k,v|
        class_variable_set(("@@"+k).to_sym, v)
      end
    end
  end
  
  def self.setup_tk_authentication
    settings = U.get_config["tk_authentication"]
    if settings.nil?
      @@tk_username = ""
      @@tk_password = ""
    else
      settings.each_pair do |k,v|
        class_variable_set(("@@tk_"+k).to_sym, v)
      end
    end
  end
  
end