def r_test(collection_id, save_path)
  collection = Collection.find({:id => collection_id})
  require 'rsruby'
  r = RSRuby.instance
  
end