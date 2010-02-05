# Put your extension routes here.

# map.namespace :admin do |admin|
#   admin.resources :whatever
# end  

map.resources :group_collections, :as => "c", :requirements => {:id => /[^\+]+/}
map.gc_search '/c/*group_collection_query', :controller => :group_collections, :action => :show
