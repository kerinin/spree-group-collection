class GroupCollectionsController < Spree::BaseController

  resource_controller
  actions :all

  new_action.after do
    @group_collection = GroupCollection.find_or_create_by_permalink( GroupCollection.make_permalink( params[:name], current_user ) )
    @group_collection.name = params[:name]
    @group_collection.user = current_user

    @group_collection.children, @group_collection.product_groups = GroupCollection.parse_globs( params[:children], params[:product_groups] )
  end

  create.response do |wants|
    wants.html { render :action => :show }
  end

  def create
    @group_collection = GroupCollection.new( :name => params[:name], :user => current_user )

    children, product_groups = GroupCollection.parse_globs( params[:children], params[:product_groups] )
    @group_collection.children = children
    @group_collection.product_groups = product_groups

    if @group_collection.save
      set_flash :create
      response_for :create
    else
      set_flash :create_fails
      response_for :creat_fails
    end
  end

  update.before do
    children, product_groups = GroupCollection.parse_globs( params[:children], params[:product_groups] )
    @group_collection.children = children
    @group_collection.product_groups = product_groups
  end

  private

  def object
    if params[:group_collection_query]
      @object = GroupCollection.from_glob( params[:group_collection_query] )
    elsif params[:id]
      @object = GroupCollection.find_by_permalink!( params[:id] )
    else
      @object = GroupCollection.new()
    end
    @object
  end
end

