class Admin::GroupCollectionsController < Admin::BaseController
  resource_controller

  new.before do
    gc_user = User.find_by_id( params[:user] )
    @group_collection = GroupCollection.find_or_create_by_permalink( GroupCollection.make_permalink( params[:name], gc_user ) )
    @group_collection.name = params[:name]
    @group_collection.user = gc_user

    @group_collection.children, @group_collection.product_groups = GroupCollection.parse_globs( params[:children], params[:product_groups] )
    @group_collection.save!
  end

  show.before do
    unless params[:id]
      @group_collection = GroupCollection.from_glob( params[:group_collection_query] )
    end
  end
end

