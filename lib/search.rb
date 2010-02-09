module Forge::Search
  def current_location
    "location!"
  end
  
  def inject_session_data_into(scopes) 
    scopes.each do |scope| 
      attribute_names = Scopes::Product::SCOPES.map{|group, names| names[scope.name.to_sym]}.compact.first 
      if attribute_names && attribute_names.include?(:user_id) 
        scope.attributes[attribute_names.index(:user_id)] = current_user.id 
      elsif attribute_names && attribute_names.include?(:request_location)
        scope.attributes[attribute_names.index(:request_location)] = current_location  
      end
    end
  end 
  
  def retrieve_products
    # taxon might be already set if this method is called from TaxonsController#show
    @taxon ||= Taxon.find_by_id(params[:taxon]) unless params[:taxon].blank?
    # add taxon id to params for searcher
    params[:taxon] = @taxon.id if @taxon
    @keywords = params[:keywords]
    per_page = params[:per_page] || Spree::Config[:products_per_page]
    params[:per_page] = per_page
    curr_page = Spree::Config.searcher.manage_pagination ? 1 : params[:page]
    # Prepare a search within the parameters
    Spree::Config.searcher.prepare(params)

    if params[:product_group_name]
      @product_group = ProductGroup.find_by_permalink(params[:product_group_name])
    elsif params[:product_group_query]
      @product_group = ProductGroup.new.from_route(params[:product_group_query])
    else
      @product_group = ProductGroup.new
    end

    @product_group.add_scope('in_taxon', @taxon) unless @taxon.blank?
    @product_group.add_scope('keywords', @keywords) unless @keywords.blank?
    @product_group = @product_group.from_search(params[:search]) if params[:search]
    
    params[:search] = @product_group.scopes_to_hash if @keywords.blank?
    
    inject_session_data_into @product_group.product_scopes

    base_scope = Spree::Config[:allow_backorders] ? Product.active : Product.active.on_hand
    @products_scope = @product_group.apply_on(base_scope)

    @products = @products_scope.paginate({
        :include  => [:images, :master],
        :per_page => per_page,
        :page     => curr_page
      })
    @products_count = @products_scope.count

    return(@products)
  end
end
