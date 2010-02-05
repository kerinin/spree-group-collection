require File.dirname(__FILE__) + '/../test_helper'

class GroupCollectionsControllerTest < ActionController::TestCase
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
      
      @gc1 = Factory :group_collection, :product_groups => [@pg1, @pg2], :user => @user
      @gc2 = Factory :group_collection, :product_groups => [@pg3], :children => [@gc1]
    end
    
    should_route :get, '/c', :controller => :group_collections, :action => :index
    context "on GET to :index" do
      setup do
        get :index
      end
      
      should_assign_to :group_collections
      should_respond_with :success
    end
 
    should_route :get, '/c/1', :controller => :group_collections, :action => :show, :id => 1
    # NOTE: this seems to be failing due to a Shoulda problem
    # should_route :get, '/c/1+2/a+b', :controller => :group_collections, :action => :show, "group_collection_query"=> ["1+2", "a+b"]
    context "on GET to :show with named gc" do
      setup do
        get :show, :id => @gc1.to_param
      end
      
      should_assign_to :group_collection
      should_respond_with :success
    end 
    
    context "on GET to :show with composite gc" do
      setup do
        get :show, :group_collection_query => ["#{@gc1.to_param}+#{@gc2.to_param}", "#{@pg1.permalink}+#{@pg2.permalink}"]
      end
      
      should_assign_to :group_collection
      should_respond_with :success
    end  
  end
end
