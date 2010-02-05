require File.dirname(__FILE__) + '/../test_helper'
 
class GroupCollectionTest < Test::Unit::TestCase
  context "A Group Collection" do
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
      
      @gc1 = Factory :group_collection, :product_groups => [@pg1, @pg2], :user => @user
      @gc2 = Factory :group_collection, :product_groups => [@pg3], :children => [@gc1]
    end
    
    teardown do
      User.delete_all
      ProductGroup.delete_all
      GroupCollection.delete_all
    end
    
    should "have some values" do
      assert @gc1.name
    end
    
    should "generate a permalink" do
      assert @gc1.permalink
    end
    
    should "have associated product product_groups" do
      assert @gc1.product_groups.include? @pg1
    end
    
    should "have associated children" do
      assert @gc2.children.include? @gc1
    end
    
    should_eventually "inherit children's product product_groups" do
      assert @gc2.product_groups.include? @pg1
    end
    
    should_eventually "return the union of it's product group scopes" do
      assert @gc1.products.include? @prod1
      assert @gc1.products.include? @prod2
    end
    
    should_eventually "not return products outside it's scopes" do
      assert !( @gc1.products.include? @prod3 )
    end
    
    should_eventually "return it's children's products" do
      assert @gc2.products.include? @prod1
      assert @gc2.products.include? @prod2
    end
    
    should "allow associated users" do
      assert_equal @user, @gc1.user
      assert @user.group_collections.include? @gc1
    end
  end

  context "from gc named url" do
    setup do   
      @pg1 = Factory :product_group
      @pg2 = Factory :product_group
      
      @gc1 = Factory :group_collection, :product_groups => [@pg1]
      @gc2 = Factory :group_collection, :product_groups => [@pg2] 
      
      @gc = GroupCollection.from_url("/c/#{@gc1.to_param}+#{@gc2.to_param}")
    end

    should "not be saved and have sane defaults" do
      assert(@gc.kind_of?(GroupCollection),
        "GroupCollection is a #{@og.class.name} instead of Group Collection")
      assert(@gc.new_record?,
        "GroupCollection is not new record")
      #assert(@gc.name.blank?,
      #  "GroupCollection.name is not blank but #{@pg.name}")
      #assert(@gc.permalink.blank?,
      #  "ObjectGroup.permalink is not blank but #{@pg.permalink}")
    end

    should "include the correct child collections" do
      assert @gc.children.include? @gc1
      assert @gc.children.include? @gc2
    end
  end
  
  context "from pg named url" do
    setup do   
      @pg1 = Factory :product_group
      @pg2 = Factory :product_group
      
      @gc1 = Factory :group_collection, :product_groups => [@pg1]
      @gc2 = Factory :group_collection, :product_groups => [@pg2] 
      
      @gc = GroupCollection.from_url("/c//#{@pg1.permalink}+#{@pg2.permalink}")
    end

    should "not be saved and have sane defaults" do
      assert(@gc.kind_of?(GroupCollection),
        "GroupCollection is a #{@og.class.name} instead of Group Collection")
      assert(@gc.new_record?,
        "GroupCollection is not new record")
      #assert(@gc.name.blank?,
      #  "GroupCollection.name is not blank but #{@pg.name}")
      #assert(@gc.permalink.blank?,
      #  "ObjectGroup.permalink is not blank but #{@pg.permalink}")
    end
    
    should "include the correct product_groups" do
      assert @gc.product_groups.include? @pg1
      assert @gc.product_groups.include? @pg2
    end
  end
  
  context "from gc+pg named url" do
    setup do   
      @pg1 = Factory :product_group
      @pg2 = Factory :product_group
      
      @gc1 = Factory :group_collection
      @gc2 = Factory :group_collection 
      
      @gc = GroupCollection.from_url("/c/#{@gc1.to_param}+#{@gc2.to_param}/#{@pg1.permalink}+#{@pg2.permalink}")
    end

    should "not be saved and have sane defaults" do
      assert(@gc.kind_of?(GroupCollection),
        "GroupCollection is a #{@og.class.name} instead of Group Collection")
      assert(@gc.new_record?,
        "GroupCollection is not new record")
      #assert(@gc.name.blank?,
      #  "GroupCollection.name is not blank but #{@pg.name}")
      #assert(@gc.permalink.blank?,
      #  "ObjectGroup.permalink is not blank but #{@pg.permalink}")
    end

    should "include the correct child collections" do
      assert @gc.children.include? @gc1
      assert @gc.children.include? @gc2
    end
        
    should "include the correct product_groups" do
      assert @gc.product_groups.include? @pg1
      assert @gc.product_groups.include? @pg2
    end
  end
end

