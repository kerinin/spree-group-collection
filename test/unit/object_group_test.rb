require File.dirname(__FILE__) + '/../test_helper'
 
class ObjectGroupTest < Test::Unit::TestCase
  context "An Object Group" do
    setup do
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
      
      @og1 = Factory :object_group, :groups => [@pg1, @pg2], :user => @user
      @og2 = Factory :object_group, :groups => [@pg3], :children => [@og1]
    end
    
    teardown do
      User.delete_all
    end
    
    should "have some values" do
      assert @og1.name
      assert @og1.description
    end
    
    should "generate a permalink" do
      assert @og1.permalink
    end
    
    should "have associated product groups" do
      assert @og1.groups.contain? @pg1
    end
    
    should "have associated children" do
      assert @og2.children.contain? @og1
    end
    
    should "inherit children's product groups" do
      assert @og2.groups.contain? @pg1
    end
    
    should "return the union of it's product group scopes" do
      assert @og1.products.contain? @prod1
      assert @og1.products.contain? @prod2
    end
    
    should "not return products outside it's scopes" do
      assert !( @og1.products.contain? @prod3 )
    end
    
    should "return it's children's products" do
      assert @og2.products.contain? @prod1
      assert @og2.products.contain? @prod2
    end
    
    should "allow associated users" do
      assert_equal @user, @og1.user
      assert @user.object_groups.contain? @og1
    end
  end
end
