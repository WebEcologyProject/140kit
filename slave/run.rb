require 'rubygems'
require 'digest/sha1'
require 'open-uri'
require 'logger'
require 'mysql'
require 'hpricot'
require 'json'
require 'eventmachine'
require 'em-http' #sudo gem install em-http-request
require 'ntp'
require 'yaml'
include NET

#########################################################
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#                    CONSTANT_LAND                      #

#Operational Shit
ROOT_FOLDER = "#{File.dirname(__FILE__)}/../"
TIME_OFFSET = NTP.get_ntp_response()["Receive Timestamp"] - Time.now.to_f
API_RATE_LIMIT_URL = "http://twitter.com/account/rate_limit_status.json"
#Streaming Instances
HOSTNAME = "http://stream.twitter.com"
TIMEOUT_MAX = 300
MAX_TRACK_IDS = 10000
MAX_ROW_COUNT_PER_BATCH = 1000
MAX_OR_STATEMENT_PER_REQUEST = 500
#REST Instances
# SITE_URL = "140kit.com"
#Worker Instances
BRANCH_CHECK_INTERVAL = 10
COUNT_CHECK_INTERVAL = 5#000
SLEEP_CONSTANT = 1#(rand 5.0)+5
ENVIRONMENT = "production"
#Analytical Flow
# Very low likeness_threshold corresponds to high branching degrees
LIKENESS_THRESHOLD = 0.50
ANALYTICAL_INTERVAL = 300
#OTHER STUFF
ERROR_THRESHOLD = 50

#                                                       #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - #
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
#########################################################

puts "\n\n\n#{Lock.new.inspect}\n\n\n"

# require "#{ROOT_FOLDER}cluster-code/environment"
# 
# #ruby run.rb stream-0 -db production
# #ruby run.rb rest-0 --database testing
# #ruby run.rb worker-0 --database production
# run_type,database,storage_location = Environment.load_arguments
# Environment.load(database)
# if !run_type.nil?
#     $w = Worker.new(run_type)
#   if run_type.include?("stream")
#     puts "Starting a streaming instance"
#     $w.instance_name = run_type
#     $w.stream
#   elsif run_type.downcase.include?("rest")
#     puts "Starting a REST instance"
#     $w.instance_name = run_type
#     $w.rest
#   else
#     puts 'Here we go...'
#     $w.instance_name = run_type
#     $w.poll
#   end
# else
#   Environment.load_production
#   Environment.load_test
#   Environment.load_development
#   Environment.set_db(Environment.pro_db)
#   puts "--Runtime Environment Loaded in IRB--\n"
# end