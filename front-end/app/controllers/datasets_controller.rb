require 'net/http'
require 'open-uri'

class DatasetsController < ApplicationController
  layout "main"
  
  before_filter :login_required, :except => [:show, :index, :track_submit, :track_preview]
  
  def new
    
  end
  
  def create
    form = params[:track_form]
    c = Curation.new
    c.name = form["term"]
    c.researcher_id = form["researcher_id"]
    
    # forcing this for now
    c.single_dataset = true
    
    c.datasets << d = Dataset.new
    d.term = form["term"]
    d.params = form["term"]
    length = (form["days"].to_i*24*60 + form["hours"].to_i*60 + form["minutes"].to_i)*60
    d.length = length
    d.scrape_type = "track"
    
    respond_to do |format|
      if c.save
        format.html { redirect_to dataset_path(c.id) }
      else
        flash[:error] = "Somthing went wrong!!!"
        format.html { redirect_to new_track_path }
      end
    end
    
  end
  
  def track_submit
    input = params[:track_form][:input]
    respond_to do |format|
      if input.empty?
        puts "\n\n1\n\n"
        flash[:error] = "You didn't enter a term to track!"
        format.html { redirect_to root_path }
      elsif logged_in?
        puts "\n\n2\n\n"
        format.html { redirect_to new_track_path(input) }
      else
        puts "\n\n3\n\n"
        format.html { redirect_to track_preview_path(input) }
      end
    end
  end
  
  def track_preview
    @term = params[:term]
    # @tweets = grab_twitter_data(@term)
    # @tweets = json_to_tweets(json)
    # logger.debug @tweets
  end
  
  def new_track
    @term = params[:term]
  end
  
  protected
  
  def grab_twitter_data(term, number=3)
    term = term.gsub(/\s+/, '+')
    api_call = "http://search.twitter.com/search.json?q=#{term}&rpp=#{number}&result_type=recent"
    raw_data = open(api_call).read
    json = JSON.parse(raw_data)
    # logger.debug json.inspect
    if !json.nil? && !json["results"].nil?
      return json["results"]
    else return nil
    end
  end
  
  def json_to_tweets(results)
    tweets = []
    for tweet_json in results
      tweet = Tweet.new
      tweet.screen_name = tweet_json["from_user"]
      tweet.text = tweet_json["text"]
      tweet.source = tweet_json["source"]
      # tweet.location = tweet_json
      # tweet.in_reply_to_screen_name = tweet_json
      # tweet.lat = tweet_json
      # tweet.lon = tweet_json
      tweet.language = tweet_json["iso_language_code"]
      logger.debug tweet.inspect
      tweets << tweet
    end
    return tweets
  end
  
end