class Rest
  
  require "#{ROOT_FOLDER}cluster-code/rester/rest_flow"
  
  attr_accessor :type, :metadata, :users, :tweets
  
  def initialize
    @metadatas = []
    @type = ""
  end
  
  def collect_rest_data
    users = []
    bad_users = []
    self.users.each do |user|
      tweets = []
      page = 1
      url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{user.screen_name}&count=200&page=#{page}"
      data = U.return_data(url)
      if !data.nil?
        data = JSON.parse(data)
        if !data.empty?
          user = user.attributes.merge(UserHelper.hash_user(data.first["user"]))
          user["flagged"] = true
          user["instance_id"] = $w.instance_id
          while !data.nil? && !data.empty?
            tweets += TweetHelper.hash_tweets(data).values.first
            page += 1
            url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{user["screen_name"]}&count=200&page=#{page}"
            data = U.return_data(url)
            data = JSON.parse(data) if !data.nil?
          end
        else 
          self.users-=[user]
          bad_users << user
        end
      else 
        self.users-=[user]
        bad_users << user
      end
      if !bad_users.include?(user)
        U.append_scrape_id({:users => user, :tweets => tweets}, self.metadata)
        User.new(user).save
        Database.save_all(:tweets => tweets)
        self.users-=[user]
      end
    end
    User.destroy_all(bad_users.collect{|bu| bu.id})
  end
  
end