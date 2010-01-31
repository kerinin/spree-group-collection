# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ObjectGroupExtension < Spree::Extension
  version "1.0"
  description "Object Groups: Collections of Product Groups (or groups of other classes)"
  url "http://github.com/kerinin/spree-object-group"

  # Please use object_group/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
  def activate

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end
  end
end
