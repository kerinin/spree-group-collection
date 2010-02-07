# Put your extension routes here.

# map.namespace :admin do |admin|
#   admin.resources :whatever
# end

map.connect 'c/:action', :controller => "group_collections"
map.resources :group_collections, :as => "c"

