require File.dirname(__FILE__) + '/../test_helper'

class GroupCollectionsTest < ActionController::IntegrationTest
  context "given data and user session" do
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

    teardown do
      User.delete_all
      Product.delete_all
      ProductGroup.delete_all
      GroupCollection.delete_all
    end

    context "on GET to :build with children + product_groups" do
      setup do
        get "/c/build?children[]=#{@gc1.to_param}&children[]=#{@gc2.to_param}&product_groups[]=#{@pg1.permalink}&product_groups[]=#{@pg2.permalink}"
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

      should "include the correct product groups" do
        assert assigns["group_collection"].product_groups.include? @pg1
        assert assigns["group_collection"].product_groups.include? @pg2
      end
    end

    context "on GET to :build with children" do
      setup do
        get "/c/build?children[]=#{@gc1.to_param}&children[]=#{@gc2.to_param}"
      end
      should_assign_to :group_collection
      should_respond_with :success
      should_render_template "show"

      should "include correct children" do
        assert_equal [@gc1, @gc2], assigns["group_collection"].children
      end
    end

    context "on GET to :build with product_groups" do
      setup do
        get "/c/build?product_groups[]=#{@pg1.permalink}&product_groups[]=#{@pg2.permalink}"
      end
      should_assign_to :group_collection
      should_respond_with :success
      should_render_template "show"
    end
  end
end

