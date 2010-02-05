class GroupCollectionsController < Spree::BaseController
  resource_controller
  
  show.before do
    unless params[:id]
      # UGLY!!!!  
      # Either refactor the from_url to use the glob array
      # or pull the url and pass it through.
      @group_collection = GroupCollection.from_url( (['/c']+params[:group_collection_query]).join('/') )
    end
  end
end

