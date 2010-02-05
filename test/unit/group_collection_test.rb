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
      
      @gc1 = Factory :group_collection, :groups => [@pg1, @pg2], :user => @user
      @gc2 = Factory :group_collection, :groups => [@pg3], :children => [@og1]
    end
    
    teardown do
      User.delete_all
    end
    
    should "have some values" do
      assert @gc1.name
      assert @gc1.description
    end
    
    should "generate a permalink" do
      assert @gc1.permalink
    end
    
    should "have associated product groups" do
      assert @gc1.groups.contain? @pg1
    end
    
    should "have associated children" do
      assert @gc2.children.contain? @gc1
    end
    
    should "inherit children's product groups" do
      assert @gc2.groups.contain? @pg1
    end
    
    should "return the union of it's product group scopes" do
      assert @gc1.products.contain? @prod1
      assert @gc1.products.contain? @prod2
    end
    
    should "not return products outside it's scopes" do
      assert !( @gc1.products.contain? @prod3 )
    end
    
    should "return it's children's products" do
      assert @gc2.products.contain? @prod1
      assert @gc2.products.contain? @prod2
    end
    
    should "allow associated users" do
      assert_equal @user, @gc1.user
      assert @user.object_groups.contain? @gc1
    end
  end

  context "from gc named url" do
    setup do   
      @pg1 = Factory :product_group
      @pg2 = Factory :product_group
      
      @gc1 = Factory :group_collection, :groups => [@pg1]
      @gc2 = Factory :group_collection, :groups => [@pg2] 
      
      @gc = GroupCollection.from_url('/c/#{gc1.to_param}+#{gc2.to_param}')
    end

    should "not be saved and have sane defaults" do
      assert(@gc.kind_of?(GroupCollection),
        "GroupCollection is a #{@og.class.name} instead of Group Collection")
      assert(@gc.new_record?,
        "GroupCollection is not new record")
      assert(@gc.name.blank?,
        "GroupCollection.name is not blank but #{@pg.name}")
      assert(@gc.permalink.blank?,
        "ObjectGroup.permalink is not blank but #{@pg.permalink}")
    end

    should "contain the correct child collections" do
      assert @gc.children.contain? @gc1
      assert @gc.children.contain? @gc2
    end
    
    should "contain the correct product groups" do
      assert @gc.groups.contain? @pg1
      assert @gc.groups.contain? @pg2
    end
  end
  
  context "from pg named url" do
    setup do   
      @pg1 = Factory :product_group
      @pg2 = Factory :product_group
      
      @gc1 = Factory :group_collection, :groups => [@pg1]
      @gc2 = Factory :group_collection, :groups => [@pg2] 
      
      @gc = GroupCollection.from_url('/c//#{@pg1.to_param}+#{@pg2.to_param}')
    end

    should "not be saved and have sane defaults" do
      assert(@gc.kind_of?(GroupCollection),
        "GroupCollection is a #{@og.class.name} instead of Group Collection")
      assert(@gc.new_record?,
        "GroupCollection is not new record")
      assert(@gc.name.blank?,
        "GroupCollection.name is not blank but #{@pg.name}")
      assert(@gc.permalink.blank?,
        "ObjectGroup.permalink is not blank but #{@pg.permalink}")
    end
    
    should "contain the correct product groups" do
      assert @gc.groups.contain? @pg1
      assert @gc.groups.contain? @pg2
    end
  end
  
  context "from gc+pg named url" do
    setup do   
      @pg1 = Factory :product_group
      @pg2 = Factory :product_group
      
      @gc1 = Factory :group_collection
      @gc2 = Factory :group_collection 
      
      @gc = GroupCollection.from_url('/c/#{@gc1.to_param}+#{@gc2.to_param}/#{@pg1.to_param}+#{@pg2.to_param}')
    end

    should "not be saved and have sane defaults" do
      assert(@gc.kind_of?(GroupCollection),
        "GroupCollection is a #{@og.class.name} instead of Group Collection")
      assert(@gc.new_record?,
        "GroupCollection is not new record")
      assert(@gc.name.blank?,
        "GroupCollection.name is not blank but #{@pg.name}")
      assert(@gc.permalink.blank?,
        "ObjectGroup.permalink is not blank but #{@pg.permalink}")
    end

    should "contain the correct child collections" do
      assert @gc.children.contain? @gc1
      assert @gc.children.contain? @gc2
    end
        
    should "contain the correct product groups" do
      assert @gc.groups.contain? @pg1
      assert @gc.groups.contain? @pg2
    end
  end
  
  context "from url" do
    setup do   
      @gc1 = Factory :group_collection
      @gc2 = Factory :group_collection 
          
      @gc = GroupCollection.from_url('/c/#{@gc1.to_param}+#{@gc2.to_param}/name_like_any/one,two,three/master_price_lt/30/descend_by_name+name_like_any/four,five,six/master_price_lt/50/descend_by_name')
    end

    should "not be saved and have sane defaults" do
      assert(@gc.kind_of?(GroupCollection),
        "GroupCollection is a #{@og.class.name} instead of Group Collection")
      assert(@gc.new_record?,
        "GroupCollection is not new record")
      assert(@gc.name.blank?,
        "GroupCollection.name is not blank but #{@pg.name}")
      assert(@gc.permalink.blank?,
        "ObjectGroup.permalink is not blank but #{@pg.permalink}")
    end
    
    should "include child groups" do
      assert @gc.children.include? @gc1
      assert @gc.children.include? @gc2
    end
    
    should "generate correct product groups" do
      assert_equal 2, @gc.groups.count
      
      assert @gc.permalink.contain? @gc.groups[0].permalink
      assert @gc.permalink.contain? @gc.groups[1].permalink
      assert_not_equal @gc.groups[1].permalink, @gc_groups[0].permalink
    end

  end
end

