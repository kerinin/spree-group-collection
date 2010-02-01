require File.dirname(__FILE__) + '/../test_helper'
 
class GroupCollectionTest < Test::Unit::TestCase
  # Uncomment the Scopes::Dynamic eval in group_collection_extension.rb for these tests to pass
  
  context "A product group" do
    setup do
      @prod1 = Factory :product, :price => 3
      @prod2 = Factory :product, :price => 10
      
      @pg = Factory(:product_group).add_scope( 'price_range', [1,5] )
    end
    
    should "return scoped products" do
      assert @pg.products.include? @prod1
      assert !( @pg.products.include? @prod2 )
    end
    
    should "apply scope" do
      assert @pg.apply_on(Product).include? @prod1
      assert !( @pg.apply_on(Product).include? @prod2 )
    end
    
    teardown do
      Product.delete_all
      ProductGroup.delete_all
      ProductScope.delete_all
    end
  end
end
