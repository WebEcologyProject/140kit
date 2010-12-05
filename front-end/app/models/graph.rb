class Graph < ActiveRecord::Base
  belongs_to :collection
  has_many :edges
  has_many :graph_points
  belongs_to :curation
  
  def self.resolve_chart_settings(title)
    universals = ", height: 500, width:920, is3D: true"
    case title
    when "tweet_location"
      # return "PieChart", "title: 'Tweet Locations'" + universals
      # return "GeoMap", "region: 'world', colors: [0xFF8747, 0xFFB581, 0xc06000], dataMode: 'markers', showLegend: false"
      return "Table", "pageSize: 100, page: 'enable', showRowNumber: true, startPage: 0, allowHtml: true, title: 'Tweet Locations'" + universals
    when "tweet_language"
      return "PieChart", "pieMinimalAngle: 1, title: 'Tweet Language'" + universals
    when "tweet_created_at"
      return "LineChart", "title: 'Tweet Publish Times', titleX: 'Date of Tweet Posting', titleY: 'Number of Tweets Published'" + universals
    when "tweet_source"
      return "PieChart", "height:500, pieMinimalAngle: 1, title: 'Tweet Sources'" + universals
    when "user_created_at"
      return "LineChart", "title: 'Account Creation', titleX: 'Date of Account Creation', titleY: 'Number of Users Created'" + universals
    when "user_favourites_count"
      return "LineChart", "title: 'User Favourites Counts', titleX: '# of Users with Y favourites', titleY: '# of favourites'" + universals
    when "user_statuses_count"
      return "LineChart", "title: 'User Statuses Counts', titleX: '# of Users with Y statuses', titleY: '# of statuses'" + universals
    when "user_followers_count"
      return "LineChart", "title: 'User Follower Counts', titleX: '# of Users with Y followers', titleY: '# of followers'" + universals
    when "user_friends_count"
      return "LineChart", "title: 'User Friend Counts', titleX: '# of Users with Y friends', titleY: '# of friends'" + universals
    when "user_time_zone"
      return "PieChart", "pieMinimalAngle: 1,is3D: true, title: 'User Time Zones'" + universals
    when "user_lang"
      return "PieChart", "pieMinimalAngle: 1, title: 'User Languages'" + universals
    when "user_geo_enabled"
      return "PieChart", "pieMinimalAngle: 1, title: 'User Geo Enabled?'" + universals
    when "hashtags"
      return "Table", "pageSize: 100, page: 'enable', showRowNumber: true, startPage: 0, allowHtml: true, title: 'Hashtag Frequency'" + universals
    when "mentions"
      return "Table", "pageSize: 100, page: 'enable', showRowNumber: true, startPage: 0, allowHtml: true, title: 'Mention Frequency'" + universals
    when "significant_words"
      return "Table", "pageSize: 100, page: 'enable', showRowNumber: true, startPage: 0, allowHtml: true, title: 'Significant Words'" + universals
    when "urls"
      return "Table", "pageSize: 100, page: 'enable', showRowNumber: true, startPage: 0, allowHtml: true, title: 'URLs'" + universals
    end
  end
end
