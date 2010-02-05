# Put your extension routes here.

# map.namespace :admin do |admin|
#   admin.resources :whatever
# end  

map.gc_index '/c/', :controller => :group_collections, :action => :index
map.gc_search '/c/:group_collection_name', :controller => :group_collections, :action => :show
