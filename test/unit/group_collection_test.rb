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

      @gc1 = Factory :group_collection, :product_groups => [@pg1, @pg2], :user => @user, :name => "group collection"
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
      assert @gc2.permalink
    end

    should "generate a user-specific permalink for owned gc's" do
      assert_equal "group-collection#{@user.id}", @gc1.permalink
    end

    should "have associated product product_groups" do
      assert @gc1.product_groups.include? @pg1
    end

    should "have associated children" do
      assert @gc2.children.include? @gc1
    end

    should "inherit children's product_groups" do
      assert @gc2.all_product_groups.include? @pg1
    end

    should "allow associated users" do
      assert_equal @user, @gc1.user
      assert @user.group_collections.include? @gc1
    end

    should "not allow multiple identical permalinks" do
      assert_raises ActiveRecord::RecordInvalid do
        group1 = Factory :group_collection
        group2 = Factory :group_collection
        group2.permalink = group1.permalink
        group2.save!
      end
    end
  end
end

