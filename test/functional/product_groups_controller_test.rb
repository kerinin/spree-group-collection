require File.dirname(__FILE__) + '/../test_helper'

class ProductGroupsControllerTest < ActionController::TestCase
  context "given data and user session" do
    setup do
      @admin = Factory :admin_user
      @user = Factory :user
      UserSession.create(@user)

      @prod1 = Factory :product, :name => 'prod1'
      @prod2 = Factory :product, :name => 'prod2'
      @prod3 = Factory :product, :name => 'prod3'

      @pg1 = Factory :product_group, :user => @user
      @pg2 = Factory :product_group
      @pg3 = Factory :product_group

      @pg1.add_scope 'in_name', ['prod1']
      @pg2.add_scope 'in_name', ['prod2']
      @pg3.add_scope 'in_name', ['prod3']
    end

    teardown do
      User.delete_all
      Product.delete_all
      ProductGroup.delete_all
      GroupCollection.delete_all
    end

    context "on GET to :new" do
      setup do
        get :new
      end
      should_respond_with :success
    end

    context "on POST to :create" do
      setup do
        post( :create, {
          :product_group => { :name => "create name" },
          :product_scope => {
            'master_price_lt'=>{:arguments =>'10', :active => true},
            'master_price_gt' => {:arguments => '5', :active => true}
          },
          :order_scope => 'descend_by_name'
          }
        )
      end
      should_assign_to :product_group
      should_redirect_to( 'product_group#show' ) { product_group_url( assigns['product_group'] ) }
      should_set_the_flash_to "Successfully created!"

      should "create a new named product group" do
        assert_equal "create name", assigns['product_group'].name
        assert_equal "create-name#{@user.id}", assigns['product_group'].permalink
        assert_equal assigns['product_group'].product_scopes[0].name, 'master_price_gt'
        assert_equal assigns['product_group'].product_scopes[0].arguments, '5'
        assert_equal assigns['product_group'].product_scopes[1].name, 'master_price_lt'
        assert_equal assigns['product_group'].product_scopes[1].arguments, '10'
        assert_equal assigns['product_group'].product_scopes[2].name, 'descend_by_name'
        assert_equal 3, assigns['product_group'].product_scopes.count
      end

      should "set to the product group's user to current" do
        assert_equal @user, assigns['product_group'].user
      end
    end

    context "on GET to :edit" do
      setup do
        get :edit, :id => @pg1.to_param
      end
      should_assign_to :product_group
      should_respond_with :success

      should "load the correct product group" do
        assert_equal @pg1, assigns["product_group"]
      end
    end

    context "on GET to :edit for non-owned gc" do
      setup do
        get :edit, :id => @pg2.to_param
      end
      should_respond_with :redirect
    end

    context "on PUT to :update" do
      setup do
        put :update, { :id => @pg1.to_param, :product_group => { :name => "new name" }, :product_scope => { 'master_price_lt'=>{:arguments =>'10', :active => true}, 'master_price_gt' => {:arguments => '5', :active => true} }, :order_scope => 'descend_by_name' }
      end
      should_assign_to :product_group
      should_respond_with :redirect
      should_redirect_to( "edit product group" ) { product_group_url(@pg1) }

      should "update parameters" do
        assert_equal assigns['product_group'].name, "new name"
        assert_equal assigns['product_group'].product_scopes[1].name, 'master_price_lt'
        assert_equal assigns['product_group'].product_scopes[1].arguments, '10'
        assert_equal assigns['product_group'].product_scopes[0].name, 'master_price_gt'
        assert_equal assigns['product_group'].product_scopes[0].arguments, '5'
        assert_equal assigns['product_group'].product_scopes[2].name, 'descend_by_name'
        assert_equal 3, assigns['product_group'].product_scopes.count
      end
    end

    context "on PUT to :update for non-owned pg" do
      setup do
        put :update, {:id => @pg2.to_param}
      end
      should_respond_with :redirect
      should_redirect_to( "Authorization Failure" ) { "/user_sessions/authorization_failure" }
    end

    context "on GET to :destroy" do
      setup do
        get :destroy, {:id => @pg1.to_param}
      end
      should_respond_with :redirect
      should_redirect_to( "product group index" ) { product_groups_url }
    end

    context "on GET to :destroy for non-owned pg" do
      setup do
        get :destroy, {:id => @pg2.to_param}
      end
      should_respond_with :redirect
      should_redirect_to( 'Authorization Failure' ) { "/user_sessions/authorization_failure" }
    end
  end
end

