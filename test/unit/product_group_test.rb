require File.dirname(__FILE__) + '/../test_helper'

class ProductGroupTest < Test::Unit::TestCase

  context "A product group" do
    setup do
      @user = Factory :user
      @pg = Factory :product_group, :name => 'pg name', :user => @user
    end

    should "allow associated users" do
      assert_equal @user, @pg.user
    end

    should "generate user-specific permalinks" do
      assert_equal "pg-name#{@user.id}", @pg.permalink
    end

    teardown do
      User.delete_all
      Product.delete_all
      ProductGroup.delete_all
      ProductScope.delete_all
    end
  end

  # Uncomment the Scopes::Dynamic eval in group_collection_extension.rb for these tests to pass
  # NOTE: it's probably better to define the named scope in the test iteself
  context "A dynamic product group" do
    setup do
      @prod1 = Factory :product, :price => 3
      @prod2 = Factory :product, :price => 10

      #@pg = Factory(:product_group).add_scope( 'price_range', [1,5] )
    end

    should_eventually "return scoped products" do
      assert @pg.products.include? @prod1
      assert !( @pg.products.include? @prod2 )
    end

    should_eventually "apply scope" do
      assert @pg.apply_on(Product).include? @prod1
      assert !( @pg.apply_on(Product).include? @prod2 )
    end

    teardown do
      User.delete_all
      Product.delete_all
      ProductGroup.delete_all
      ProductScope.delete_all
    end
  end
end

