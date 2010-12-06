ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'application', :action => 'welcome'
  map.account '/account', :controller => 'researchers', :action => 'show'
  map.account_forgot '/forgot', :controller => 'account', :action => 'forgot'
  map.account_reset 'reset/:reset_code', :controller => 'account', :action => 'reset'
  map.welcome '/welcome', :controller => 'researchers', :action => 'welcome'
  # map.analytical_offerings_collection_paginate '/analytical_offerings/collection_paginate/:id', :controller => 'stream_metadatas', :action => 'collection_paginate'
  # map.analytical_offerings_associate '/analytical_offerings/:analytical_offering_id/associate/:collection_id', :controller => 'stream_metadatas', :action => 'associate'
  # map.analytical_offerings_dissociate '/analytical_offerings/:analytical_offering_id/dissociate/:collection_id', :controller => 'stream_metadatas', :action => 'dissociate'
  
  map.track_preview '/track/preview/:term', :controller => 'datasets', :action => 'track_preview'
  map.new_track '/track', :controller => 'datasets', :action => 'new_track'
  map.new_track '/track/:term', :controller => 'datasets', :action => 'new_track'
  map.create_dataset '/datasets/create', :controller => 'datasets', :action => 'create'
  map.track_submit '/datasets/submit', :controller => 'datasets', :action => 'track_submit'
  
  map.new_dataset '/datasets/new', :controller => 'datasets', :action => 'new'
  
  map.collections '/collections', :controller => 'collections', :action => 'index', :single_dataset => 'false'
  map.collections_sort '/collections/sort/:sort', :controller => 'collections', :action => 'index', :single_dataset => 'false'  
  map.collections_manage '/collections/manage', :controller => 'collections', :action => 'manage'
  map.collection_add '/collections/add', :controller => 'collections', :action => 'creator'
  map.create_collection '/collections/create', :controller => 'collections', :action => 'create'
  map.analytical_setup '/collections/:id/analytical_setup', :controller => 'collections', :action => 'analytical_setup'
  map.collection_alter '/collections/:id/alter', :controller => 'collections', :action => 'alter'
  map.datasets_curate '/collections/:id/datasets', :controller => 'stream_metadatas', :action => 'curate'
  map.analytical_offerings_curate '/collections/:id/analytical_offerings', :controller => 'analytical_offerings', :action => 'curate'
  map.collection_add_analytics '/collections/:collection_id/add/analytics/:analytical_offering_id', :controller => 'collections', :action => 'add_analytics'
  map.collection_remove_analytics '/collections/:collection_id/remove/analytics/:analytical_offering_id', :controller => 'collections', :action => 'remove_analytics'
  map.collection_mothball '/collections/:collection_id/mothball', :controller => 'collections', :action => 'mothball'
  map.collection_hide '/collections/:collection_id/hide', :controller => 'collections', :action => 'hide'
  map.collection_rollback '/collections/:collection_id/rollback', :controller => 'collections', :action => 'rollback'
  map.collection_full_destroy '/collections/:collection_id/full_destroy', :controller => 'collections', :action => 'full_destroy'
  
  # map.datasets '/datasets', :controller => 'collections', :action => 'index', :single_dataset => 'true'
  # map.dataset '/datasets/:id', :controller => 'collections', :action => 'show'
  map.datasets '/datasets', :controller => 'curations', :action => 'index'
  map.dataset '/datasets/:id', :controller => 'curations', :action => 'show'
  map.curation '/datasets/:id', :controller => 'curations', :action => 'show'
  map.add_curation '/datasets/:id', :controller => 'curations', :action => 'show'
  map.destroy_curation '/datasets/:id/destroy', :controller => 'curations', :action => 'destroy'
  
  #ANALYSIS ROUTES
  
  map.hour_report_menu '/graphs/:collection_id/timeline/selection/:selection/:year/:month/:date', :controller => 'analysis_metadatas', :action => 'reveal_menu'
  map.date_report_menu '/graphs/:collection_id/timeline/selection/:selection/:year/:month', :controller => 'analysis_metadatas', :action => 'reveal_menu'
  map.month_report_menu '/graphs/:collection_id/timeline/selection/:selection/:year', :controller => 'analysis_metadatas', :action => 'reveal_menu'

  map.show_hour_report '/graphs/:collection_id/timeline/show/:year/:month/:date/:hour', :controller => 'analysis_metadatas', :action => 'timeline_menu'
  map.show_date_report '/graphs/:collection_id/timeline/show/:year/:month/:date', :controller => 'analysis_metadatas', :action => 'timeline_menu'
  map.show_month_report '/graphs/:collection_id/timeline/show/:year/:month', :controller => 'analysis_metadatas', :action => 'timeline_menu'
  map.show_year_report '/graphs/:collection_id/timeline/show/:year', :controller => 'analysis_metadatas', :action => 'timeline_menu'

  map.hour_report '/graphs/:collection_id/timeline/:year/:month/:date/:hour', :controller => 'graphs', :action => 'timeline'
  map.date_report '/graphs/:collection_id/timeline/:year/:month/:date', :controller => 'graphs', :action => 'timeline'
  map.month_report '/graphs/:collection_id/timeline/:year/:month', :controller => 'graphs', :action => 'timeline'
  map.year_report '/graphs/:collection_id/timeline/:year', :controller => 'graphs', :action => 'timeline'
  
  map.google_graph '/graphs/google/:id', :controller => 'graphs', :action => 'show'
  
  map.login '/login', :controller => 'account', :action => 'login'
  map.logout '/logout', :controller => 'account', :action => 'logout'
  
  
  map.dgraph '/dgraph/:collection_id/:style', :controller => 'networks', :action => 'dgraph'
  map.dgraph_with_logic '/dgraph/:collection_id/:style/:logic', :controller => 'networks', :action => 'dgraph'

  map.networks '/networks', :controller => 'networks', :action => 'index'
  map.rgraph '/networks/:collection_id/:style', :controller => 'networks', :action => 'show'
  map.rgraph_with_logic '/networks/:collection_id/:style/:logic', :controller => 'networks', :action => 'show'
  
  map.flare '/networks/:collection_id/:style', :controller => 'networks', :action => 'flare'
  map.flare_with_logic '/networks/:collection_id/:style/:logic', :controller => 'networks', :action => 'flare'
  
  map.netwerk '/netwerks/:collection_id/:style', :controller => 'networks', :action => 'sh0w'
  map.netwerk_with_logic '/netwerks/:collection_id/:style/:logic', :controller => 'networks', :action => 'sh0w'

  map.news '/news', :controller => 'news', :action => 'create', :conditions => {:method => :post}
  map.news '/news', :controller => 'news', :action => 'index'
  map.new_news '/news/new', :controller => 'news', :action => 'new'
  map.news_manage 'news/manage', :controller => 'news', :action => 'manage'
  map.news '/news/:id', :controller => 'news', :action => 'update', :conditions => {:method => :put}
  map.news '/news/:id', :controller => 'news', :action => 'destroy', :conditions => {:method => :delete}
  map.news '/news/:id', :controller => 'news', :action => 'show'
  map.edit_news '/news/:id/edit', :controller => 'news', :action => 'edit'
  map.page_item 'pages/:slug', :controller => 'news', :action => 'show'
  map.page_item 'pages/:id/:slug', :controller => 'news', :action => 'show'
  
  map.researchers '/researchers', :controller => 'researchers', :action => 'index'

  map.new_scrape '/scrapes/new/:scrape_type', :controller => 'scrapes', :action => 'new'
  
  map.dataset_search '/search/datasets', :controller => 'collections', :action => 'search'
  map.search '/search', :controller => 'application', :action => 'search'
  
  map.settings '/settings/:id', :controller => 'researchers', :action => 'edit'
  map.signup '/signup', :controller => 'account', :action => 'signup'
    
  map.datasets_curate '/collections/:id/metadatas', :controller => 'collections', :action => 'curate'
  map.datasets_associate '/metadatas/:metadata_id/:metadata_type/associate/:collection_id', :controller => 'collections', :action => 'associate'
  map.datasets_dissociate '/metadatas/:metadata_id/:metadata_type/dissociate/:collection_id', :controller => 'collections', :action => 'dissociate'
  
  map.tweets_collection_paginate '/tweets/collection_paginate/:id', :controller => 'tweets', :action => 'collection_paginate'
  map.tweets_collection_paginate_dataset '/tweets/collection_paginate/dataset/:metadata_type/:id', :controller => 'tweets', :action => 'collection_paginate_dataset'
  
  map.user '/users/:screen_name', :controller => 'users', :action => 'show'
  map.users_collection_paginate '/users/collection_paginate/:id', :controller => 'users', :action => 'collection_paginate'
  map.users_collection_paginate_dataset '/users/collection_paginate/dataset/:metadata_type/:id', :controller => 'users', :action => 'collection_paginate_dataset'

  #ADMIN
  map.new_tickets '/tickets', :controller => 'comments', :action => 'new'
  map.tickets_manage '/tickets/manage', :controller => 'comments', :action => 'index'  
  map.instance_show '/instances/:instance_type/:instance_id', :controller => 'cluster', :action => 'instance_show' 
  map.machine_show '/machines/:slug', :controller => 'cluster', :action => 'machine_show'
  map.analytical_offerings_manage 'analytical_offerings/manage', :controller => 'analytical_offerings', :action => 'manage'
  map.analytical_offering_enable 'analytical_offerings/enable/:id', :controller => 'analytical_offerings', :action => 'enable'
  map.researchers_manage 'researchers/manage', :controller => 'researchers', :action => 'manage'
  map.researcher_promote '/researchers/promote/:id', :controller => 'researchers', :action => 'promote'
  map.researcher_access '/researchers/access/:id', :controller => 'researchers', :action => 'access_level'
  map.researcher_suspend '/researchers/suspend/:id', :controller => 'researchers', :action => 'suspend'
  map.manage_cluster '/cluster/manage', :controller => 'cluster', :action => 'manage'
  map.kill_instance '/instances/kill/:instance_type/:id', :controller => 'cluster', :action => 'kill_instance'
  map.resurrect_instance '/instances/resurrect/:instance_type/:id', :controller => 'cluster', :action => 'resurrect_instance'
  map.machine_form '/machines/form/:instance_type/:slug/:submit_type', :controller => 'cluster', :action => 'machine_form'
  map.restart_machine_jobs '/machines/:instance_type/:slug/restart', :controller => 'cluster', :action => 'restart_machine_jobs'
  map.reassign_machine_jobs '/machines/:instance_type/:slug/reassign', :controller => 'cluster', :action => 'reassign_machine_jobs'
  map.job_form '/jobs/form/:instance_type/:id/:submit_type', :controller => 'cluster', :action => 'job_form'
  map.restart_job '/jobs/:instance_type/:id/restart', :controller => 'cluster', :action => 'restart_job'
  map.reassign_job '/jobs/:instance_type/:id/reassign', :controller => 'cluster', :action => 'reassign_job'
  map.datasets_collection_paginate '/datasets/collection_paginate/:id', :controller => 'collections', :action => 'dataset_paginate'
  map.metadata '/metadatas/:metadata_type/:metadata_id', :controller => 'stream_metadatas', :action => 'show'

  map.resources :whitelistings
  map.resources :auth_users
  map.resources :analytical_instances
  map.resources :analytical_offerings
  map.resources :stream_instances
  map.resources :rest_instances
  map.resources :analytical_instances
  map.resources :analysis_metadatas
  map.resources :analytical_offerings
  map.resources :collections
  map.resources :comments
  map.resources :edges
  map.resources :failures
  map.resources :graph_points
  map.resources :images
  map.resources :pending_emails
  map.resources :researchers
  map.resources :scrapes
  map.resources :stream_instances
  map.resources :tweets
  map.resources :users 
  map.resources :curations
  
  map.connect '/:controller/:action/:id'
  map.connect '/:controller/:action/:id.:format'
  map.researcher_page '/:user_name', :controller => 'researchers', :action => 'show'
  map.collection '/:user_name/collections/:id', :controller => 'collections', :action => 'show'
  
  
end
