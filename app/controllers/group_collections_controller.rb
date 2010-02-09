class GroupCollectionsController < Spree::BaseController
  prepend_before_filter :load_children, :only => [:build, :create, :update]
  prepend_before_filter :load_product_groups, :only => [:build, :create, :update]

  resource_controller

  actions :all, :build

  create.before do
    @group_collection.user = current_user
  end

  def build
    @group_collection = GroupCollection.new()
    @group_collection.children = params[:group_collection][:children]
    @group_collection.product_groups = params[:group_collection][:product_groups]

    render :action => :show
  end

  private

  def build_object
    # NOTE: ok, so this is a bit of a hack
    # The idea is that if we save an object with an existing name, it will overwrite
    # the original rather than making a new object.
    if params[:group_collection] && params[:group_collection][:name]
      permalink = GroupCollection.make_permalink( params[:group_collection][:name], current_user)
      @object = GroupCollection.find_or_create_by_permalink( permalink )
      object.update_attributes object_params
    else
      @object = GroupCollection.new(object_params)
    end
  end

  def load_children
    params[:group_collection] ||= {}
    params[:group_collection][:children] = params[:children].to_a.map{|permalink| GroupCollection.find_by_permalink(permalink) }.compact.uniq
  end

  def load_product_groups
    params[:group_collection] ||= {}
    params[:group_collection][:product_groups] = params[:product_groups].to_a.map{|permalink| ProductGroup.find_by_permalink(permalink) }.compact.uniq
  end
end

