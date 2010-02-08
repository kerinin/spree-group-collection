# Put your extension routes here.

# map.namespace :admin do |admin|
#   admin.resources :whatever
# end

map.build_group_collection 'c/build', :controller => "group_collections", :action => "build"
map.resources :group_collections, :as => "c"
map.resources :product_groups

