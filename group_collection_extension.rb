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

    User.class_eval do
      has_many :group_collections, :dependent => :destroy, :order => :position
      has_many :product_groups, :dependent => :destroy
    end

    ProductGroup.class_eval do
      belongs_to :user

      def set_permalink
        self.permalink = "#{self.name.to_url}#{user.id unless user.nil?}"
      end
    end

  end
end

