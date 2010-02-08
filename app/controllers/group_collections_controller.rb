class GroupCollectionsController < Spree::BaseController
  prepend_before_filter :load_children, :only => [:build, :create, :update]
  prepend_before_filter :load_product_groups, :only => [:build, :create, :update]

  resource_controller

  actions :all, :build

  create.before do
    #@group_collection.name = params[:name]
    @group_collection.user = current_user

    #@group_collection.children = params[:children]
    #@group_collection.product_groups = params[:product_groups]
  end

  def build
    @group_collection = GroupCollection.new()
    @group_collection.children = params[:group_collection][:children]
    @group_collection.product_groups = params[:group_collection][:product_groups]

    render :action => :show
  end

  update.before do
    #@group_collection.children = params[:children]
    #@group_collection.product_groups = params[:product_groups]
  end

  private

  def build_object
    if params[:group_collection] && params[:group_collection][:name]
      permalink = GroupCollection.make_permalink( params[:group_collection][:name], current_user)
      @object = GroupCollection.find_or_create_by_permalink( permalink )
    else
      @object = GroupCollection.new()
    end
    @group_collection = @object
    @object
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

