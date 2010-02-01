# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'
class GroupCollectionExtension < Spree::Extension
  version "1.0"
  description "Group Collection: Collections of Product Groups (or groups of other classes)"
  url "http://github.com/kerinin/spree-group-collection"

  # Please use group_collection/config/routes.rb instead for extension routes.

  def self.require_gems(config)
    config.gem "shoulda", :version => '2.10.2'
    config.gem "factory_girl", :version => '1.2.3'
  end
  
  def activate

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end
    
    # Define dynamic scopes
    # Dynamic scopes can be included in a Product Group by using the scope's name
    # Arguments are passed as usual, but the scope should have access to
    # stateful information (ie, the current request or logged-in user)
    #
    # Scopes::Dynamic.module_eval do
    #   def price_range(low=0, high=nil)
    #     scopes = []
    #    
    #     scopes << ProductScope.new({
    #         :name => "price_between",
    #         :arguments => [low, high]
    #     })   
    #     
    #     scopes
    #   end
    #   module_function :price_range
    # end

    ProductScope.class_eval do
      extend Scopes::Dynamic
      
      def apply_scopes( scopish )
        scoped = scopish
        ProductScope.send( self.name, *self.arguments ).each do |scope|
          scoped = scope.apply_on( scopish )
        end
        scoped
      end
      
      # Get all products with this scope
      def products
        if Scopes::Dynamic.respond_to?(self.name)
          apply_scopes( Product )
        elsif Product.condition?(self.name)
          Product.send(self.name, *self.arguments)
        end
      end

      # Applies product scope on Product model or another named scope
      def apply_on(another_scope)
        if Scopes::Dynamic.respond_to?(self.name)
          apply_scopes( another_scope )
        else
          another_scope.send(self.name, *self.arguments)
        end
      end  
      
      # checks validity of the named scope (if it's safe and can be applied on Product)
      def validate
        errors.add(:name, "is not propper scope name") unless ( Product.condition?(self.name) || Scopes::Dynamic.respond_to?(self.name) )
        apply_on(Product)
      rescue Exception
        errors.add(:arguments, "arguments are incorrect")
      end
    end
  end
end
