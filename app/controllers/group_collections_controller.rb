class GroupCollectionsController < Spree::BaseController
  prepend_before_filter :load_children, :only => [:build, :create, :update]
  prepend_before_filter :load_product_groups, :only => [:build, :create, :update]

  resource_controller

  actions :all, :build

  create.response do |wants|
    wants.html { render :action => :show }
  end

  def create
    permalink = GroupCollection.make_permalink( params[:name], current_user)
    @group_collection = GroupCollection.find_or_create_by_permalink( permalink )
    @group_collection.name = params[:name]
    @group_collection.user = current_user

    @group_collection.children = params[:children]
    @group_collection.product_groups = params[:product_groups]

    # NOTE: bring this back in line with the original in case you
    # want to use before, after, whatever
    if @group_collection.save
      set_flash :create
      response_for :create
    else
      set_flash :create_fails
      response_for :creat_fails
    end
  end

  def build
    @group_collection = GroupCollection.new()
    @group_collection.children = params[:children]
    @group_collection.product_groups = params[:product_groups]

    @children = params[:children]
    @product_groups = params[:product_groups]

    render :action => :show
  end

  update.before do
    @group_collection.children = params[:children]
    @group_collection.product_groups = params[:product_groups]
  end

  private

  def load_children
    params[:children] = [] if params[:children].nil?
    children_array = params[:children].split('+')
    params[:children] = children_array.map{|permalink| child = GroupCollection.find_by_permalink(permalink); child ? child : nil }.compact.uniq
  end

  def load_product_groups
    params[:product_groups] = [] if params[:product_groups].nil?
    product_groups_array = params[:product_groups].split('+')
    params[:product_groups] = product_groups_array.map{|permalink| pg = ProductGroup.find_by_permalink(permalink); pg ? pg : nil }.compact.uniq
  end
end

