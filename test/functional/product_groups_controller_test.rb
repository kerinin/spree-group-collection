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
        post :create, { :name => "new name", {:order_scope => 'ascend_price':product_scope => { 'name_like'=>'foo', 'price_between' => '5,10' }} }
      end
      should_assign_to :product_group
      should_respond_with :success
      should_render_template 'show'
      should_set_the_flash_to "Successfully created!"

      should "create a new named product group" do
        assert_equal "new name", assigns['product_group'].name
        assert_equal "new-name#{@user.id}", assigns['product_group'].permalink
        assert_equal assigns['product_group'].product_scopes[0].name, 'name_like'
        assert_equal assigns['product_group'].product_scopes[0].arguments, 'foo'
        assert_equal assigns['product_group'].product_scopes[1].name, 'price_between'
        assert_equal assigns['product_group'].product_scopes[1].arguments, '5,10'
        assert_equal assigns['product_group'].order, 'ascend_price'
      end

      should "set to the product group's user to current" do
        assert_equal @user, assigns['product_group'].user
      end
    end

    context "on repeated POST to :create" do
      setup do
        post :create, { :name => @pg1.to_param }
      end
      should_respond_with :success
      should_assign_to :product_group

      should "update the existing product group" do
        assert_equal @pg1.permalink, assigns["product group"].permalink
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
        put :update, { :id => @pg1.to_param, :name => "new name", {:order_scope => 'ascend_price':product_scope => { 'name_like'=>'foo', 'price_between' => '5,10' }} }
      end
      should_assign_to :product_group
      should_respond_with :redirect
      should_redirect_to( "edit product group" ) { product_group_url(@gc1) }

      should "update parameters" do
        assert_equal assigns['product_group'].product_scopes[0].name, 'name_like'
        assert_equal assigns['product_group'].product_scopes[0].arguments, 'foo'
        assert_equal assigns['product_group'].product_scopes[1].name, 'price_between'
        assert_equal assigns['product_group'].product_scopes[1].arguments, '5,10'
        assert_equal assigns['product_group'].order, 'ascend_price'
        assert_nil assigns['product_group'].product_scopes[2]
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
      should_redirect_to( "product group index" ) { product_group_url }
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

