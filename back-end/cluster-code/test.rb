load "run.rb"
users = User.find_all({:limit => 10})
Analysis::hashes_to_csv("blah.csv", users.collect{|u| u.attributes})