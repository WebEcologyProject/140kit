ActionController::Routing::Routes.draw do |map|
  map.resources :collections

  map.resources :pending_emails
  #Internal Routes
  map.connect '/graphs/google/:id.:format', :controller => 'graphs', :action => 'google_graph_query'
  
  #External Routes
  map.connect '/scrapes/:scrape_id/:controller.:format', :action => 'api_query'
  map.connect '/users/:twitter_id/:controller.:format', :action => 'api_query'
  map.connect '/networks/:style.graphml', :controller => 'graphs', :action => 'network_query'
  map.connect '/networks/user_network/:start_node.graphml', :controller => 'graphs', :action => 'user_network_query'
  map.connect '/networks/:collection_id/:style.:format', :controller => 'graphs', :action => 'network_query'
  map.connect '/graphs/:collection_id/:style/:title.:format', :controller => 'graphs', :action => 'graph_query'
  map.connect '/scrapes/:scrape_id/:controller/:screen_name/:sub_controller.:format', :action => 'relational_query'
  map.connect ':controller.:format', :action => 'api_query'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect '/stats.:format', :controller => 'researchers', :action => 'index'
end
