require File.dirname(__FILE__) + '/../test_helper'

# Restrict associations to null or user

class GroupCollectionsControllerTest < ActionController::TestCase
  context "given data and user session" do
    setup do
      @admin = Factory :admin_user
      @user = Factory :user
      UserSession.create(@user)

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

    teardown do
      User.delete_all
      Product.delete_all
      ProductGroup.delete_all
      GroupCollection.delete_all
    end

    should_route :get, '/c', :controller => :group_collections, :action => :index
    context "on GET to :index" do
      setup do
        get :index
      end

      should_assign_to :group_collections
      should_respond_with :success
    end

    context "on GET to :new" do
      setup do
        get :new
      end
      should_respond_with :success
    end

    context "on POST to :create" do
      setup do
        post :create, { :group_collection => { :name => "new name", :children => [@gc1.to_param,@gc2.to_param], :product_groups => [@pg1.permalink] } }
      end
      should_assign_to :group_collection
      should_respond_with :success
      should_render_template 'show'
      should_set_the_flash_to "Successfully created!"

      should "create a new named group collection" do
        assert_equal "new name", assigns['group_collection'].name
        assert_equal "new-name#{@user.id}", assigns['group_collection'].permalink
        assert assigns['group_collection'].children.include? @gc1
        assert assigns['group_collection'].children.include? @gc2
        assert assigns['group_collection'].product_groups.include? @pg1
      end

      should "set to the group collection's user to current" do
        assert_equal @user, assigns['group_collection'].user
      end
    end

    context "on repeated POST to :create" do
      setup do
        post :create, { :group_collection => { :name => @gc1.name, :children => "#{@gc2.to_param}", :product_groups => "#{@pg3.permalink}" } }
      end
      should_respond_with :success
      should_assign_to :group_collection

      should "update the existing group collection" do
        assert_equal @gc1.permalink, assigns["group_collection"].permalink
        assert assigns["group_collection"].children.include? @gc2
        assert assigns["group_collection"].product_groups.include? @pg3
        assert !( assigns["group_collection"].product_groups.include? @pg1 )
        assert !( assigns["group_collection"].product_groups.include? @pg2 )
      end
    end

    should_route :get, '/c/1', :controller => :group_collections, :action => :show, :id => 1
    context "on GET to :show with named gc" do
      setup do
        get :show, :id => @gc1.to_param
      end
      should_assign_to :group_collection
      should_respond_with :success

      should "fetch the correct group collection" do
        assert_equal assigns['group_collection'], @gc1
      end
    end

    context "on GET to :build with children + product_groups" do
      setup do
        get :build, { :children => [@gc1.to_param,@gc2.to_param], :product_groups => [@pg1.permalink,@pg2.permalink] }
      end
      should_assign_to :group_collection
      should_respond_with :success
      should_render_template "show"

      should "not be saved and have sane defaults" do
        assert(assigns["group_collection"].kind_of?(GroupCollection),
          "GroupCollection is a #{assigns["group_collection"].class.name} instead of Group Collection")
        assert(assigns["group_collection"].new_record?,
          "GroupCollection is not new record")
        assert(assigns["group_collection"].name.blank?,
          "GroupCollection.name is not blank but #{assigns["group_collection"].name}")
        assert(assigns["group_collection"].permalink.blank?,
          "ObjectGroup.permalink is not blank but #{assigns["group_collection"].permalink}")
      end

      should "include the correct child collections" do
        assert assigns["group_collection"].children.include? @gc1
        assert assigns["group_collection"].children.include? @gc2
      end
    end

    context "on GET to :build with children" do
      setup do
        get :build, :children => [@gc1.to_param,@gc2.to_param]
      end
      should_assign_to :group_collection
      should_respond_with :success
      should_render_template "show"
    end

    context "on GET to :build with product_groups" do
      setup do
        get :build, :product_groups => [@pg1.permalink,@pg2.permalink]
      end
      should_assign_to :group_collection
      should_respond_with :success
      should_render_template "show"
    end

    context "on GET to :edit" do
      setup do
        get :edit, :id => @gc1.to_param
      end
      should_assign_to :group_collection
      should_respond_with :success

      should "load the correct group collection" do
        assert_equal @gc1, assigns["group_collection"]
      end
    end

    context "on GET to :edit for non-owned gc" do
      setup do
        get :edit, :id => @gc2.to_param
      end
      should_respond_with :redirect
    end

    context "on PUT to :update" do
      setup do
        put :update, {:id => @gc1.permalink, :group_collection => { :children => "", :product_groups => "" } }
      end
      should_assign_to :group_collection
      should_respond_with :redirect
      should_redirect_to( "edit group collection" ) { group_collection_url(@gc1) }

      should "update parameters" do
        assert_equal assigns["group_collection"].children, []
        assert_equal assigns["group_collection"].product_groups, []
      end
    end

    context "on PUT to :update for non-owned gc" do
      setup do
        put :update, {:id => @gc2.to_param, :group_collection => { :children => "", :product_groups => ""} }
      end
      should_respond_with :redirect
      should_redirect_to( "Authorization Failure" ) { "/user_sessions/authorization_failure" }
    end

    context "on GET to :destroy" do
      setup do
        get :destroy, {:id => @gc1.to_param}
      end
      should_respond_with :redirect
      should_redirect_to( "group collection index" ) { group_collections_url }
    end

    context "on GET to :destroy for non-owned gc" do
      setup do
        get :destroy, {:id => @gc2.to_param}
      end
      should_respond_with :redirect
      should_redirect_to( 'Authorization Failure' ) { "/user_sessions/authorization_failure" }
    end
  end
end

