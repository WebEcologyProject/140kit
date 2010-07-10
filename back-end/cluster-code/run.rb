require 'rubygems'
require 'digest/sha1'
require 'open-uri'
require 'logger'
require 'mysql'
require 'hpricot'
require 'json'
require 'eventmachine'
require 'em-http'
require 'ntp'
include NET

#########################################################
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#                    CONSTANT_LAND                      #

#Operational Shit
ROOT_FOLDER = "~/TwitterGrep/back-end/"
TIME_OFFSET = NTP.get_ntp_response()["Receive Timestamp"] - Time.now.to_f
API_RATE_LIMIT_URL = "http://twitter.com/account/rate_limit_status.json"
#Streaming Instances
HOSTNAME = "http://stream.twitter.com"
TIMEOUT_MAX = 300
MAX_TRACK_IDS = 10000
MAX_ROW_COUNT_PER_BATCH = 1000
MAX_OR_STATEMENT_PER_REQUEST = 500
#Worker Instances
BRANCH_CHECK_INTERVAL = 10
COUNT_CHECK_INTERVAL = 5#000
SLEEP_CONSTANT = (rand 5.0)+5
ENVIRONMENT = "production"
#Analytical Flow
# Very low likeness_threshold corresponds to high branching degrees
LIKENESS_THRESHOLD = 0.50
ANALYTICAL_INTERVAL = 300
#Analytical Constants
ROOT_ADDRESS = "linode:/var/www/TwitterGrep/front-end/"
CSV_ADDRESS = "linode:/var/www/TwitterGrep/front-end/public/files/raw_data/raw_csv/"
SQL_ADDRESS = "linode:/var/www/TwitterGrep/front-end/public/files/raw_data/raw_sql/"
GRAPH_POINT_ADDRESS = "linode:/var/www/TwitterGrep/front-end/public/files/raw_data/graph_points/"

#                                                       #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
#########################################################

require "#{ROOT_FOLDER}cluster-code/environment"

#ruby run.rb stream-0 -db production
#ruby run.rb rest-0 --database testing
#ruby run.rb worker-0 --database production
database = nil
run_type = ARGV.shift
if ARGV.include?("-db")
  database = ARGV[ARGV.index("-db")+1]
elsif ARGV.include?("--database")
  database = ARGV[ARGV.index("--database")+1]
end
if database.nil?
  database = ENVIRONMENT
end
Environment.load(database)
if !run_type.nil?
    $w = Worker.new(run_type)
  if run_type.include?("stream")
    puts "Starting a streaming instance"
    $w.instance_name = run_type
    $w.stream
  elsif run_type.downcase.include?("rest")
    puts "Starting a REST instance"
    $w.instance_name = run_type
    $w.rest
  else
    puts 'Here we go...'
    $w.instance_name = run_type
    $w.poll
  end
else
  Environment.load_production
  Environment.load_testing
  Environment.load_development
  Environment.set_db(Environment.pro_db)
  puts "--Runtime Environment Loaded in IRB--\n"
end