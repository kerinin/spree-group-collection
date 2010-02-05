require File.dirname(__FILE__) + '/../test_helper'

# Pull associated Products
# Pull associated Projects (?)

class ProjectsControllerTest < ActionController::TestCase
  context "given data" do
    setup do
      @admin = Factory :admin_user
      @user = Factory :user
      
      @prod1 = Factory :product, :name => 'prod1'
      @prod2 = Factory :product, :name => 'prod2'
      @prod3 = Factory :product, :name => 'prod3'
      
      @pg1 = Factory :product_group
      @pg2 = Factory :product_group
      @pg3 = Factory :product_group
      
      @pg1.add_scope 'in_name', ['prod1']
      @pg2.add_scope 'in_name', ['prod2']
      @pg3.add_scope 'in_name', ['prod3']
      
      @gc1 = Factory :group_collection, :groups => [@pg1, @pg2], :user => @user
      @gc2 = Factory :group_collection, :groups => [@pg3], :children => [@og1]
    end
    
    should_route :get, '/c', :controller => :group_collection, :action => :index
    context "on GET to :index" do
      setup do
        get :index
      end
      
      should_assign_to :group_collections
      should_respond_with :success
    end
    
    should_route :get, '/c/1', :controller => :group_collection, :action => :show, :group_collection => 1
    should_route :get, '/c/1+2/a+b', :controller => :group_collection, :action => :show, :group_collection => '1+2/a+b'
    context "on GET to :show" do
      setup do
        get :index, :group_collection => @gc1.to_param
      end
      
      should _assign_to :group_collection
      should_respond_with :success
    end  
  end
end
