class ProductGroupsController < Spree::BaseController
  before_filter :set_nested_product_scopes, :only => [:create, :update]

  resource_controller

  actions :all

  create.before do
    @product_group.user = current_user
  end

  update.before do
    @product_group.user = current_user
  end

  private

  def collection
    conditions = create_conditions do | c |
      c.or ["user_id = ?", current_user] if current_user
      c.or "user_id = NULL"
      c.or "user_id = ''"
    end
    @collection ||= end_of_association_chain.find(:all, :conditions => conditions )
  end

  def set_nested_product_scopes
    if params[:product_scope]
      params[:product_group] ||= {}
      result = []
      params[:product_scope].each_pair do |k, v|
        result << {:name => k, :arguments=> v[:arguments]} if v[:active]
      end
      if os = params[:order_scope]
        result << {:name => os, :arguments => []}
      end
      object && object.product_scopes.clear
      params[:product_group][:product_scopes_attributes] = result
    end
  end
end

