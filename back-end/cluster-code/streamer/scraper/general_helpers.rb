class GeneralHelpers
  def self.pickup_lost_users(metadata_id, metadata_type)
    metadata = metadata_type.classify.constantize.find(:id => metadata_id)
    user_names = Tweet.find_all(:metadata_id => metadata_id, :metadata_type => metadata_type).collect{|x| x.screen_name }.compact.uniq
    users = []
    user_names.each do |user_name|
      url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{user_name}"
      data = U.return_data(url)
      if !data.nil?
        if !data.empty?
          data = JSON.parse(data)
          user = UserHelper.hash_user(data.first["user"])
          user["metadata_id"] = metadata_id
          user["metadata_type"] = metadata_type
          user["scrape_id"] = metadata.scrape.id
          users << user
        end
      end
    end
    Database.save_all(:users => users)
  end
end