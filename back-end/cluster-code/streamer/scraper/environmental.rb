class Environmental
  
  def self.trending_terms
    trending_terms_json = JSON.parse(U.return_data("http://search.twitter.com/trends/current.json"))
    return trending_terms_json["trends"].values.flatten.collect {|v| v["query"]}
  end
  
  def self.rate
    rate_hash = JSON.parse(open("http://twitter.com/account/rate_limit_status.json").read)
    return rate_hash["remaining_hits"]
  end
  
end