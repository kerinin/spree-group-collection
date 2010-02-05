class CreateGroupCollection < ActiveRecord::Migration
  def self.up
    create_table :group_collections do |gc|
      gc.string :name
      gc.string :permalink
      gc.string :order

      gc.belongs_to :user
      
      gc.timestamps
    end
    add_index :group_collections, :name
    add_index :group_collections, :permalink
    add_index :group_collections, :user_id
        
    create_table :product_groupings do |g|
      g.belongs_to :group_collection
      g.belongs_to :product_group
    end
    add_index :product_groupings, :group_collection
    add_index :product_groupings, :product_group
    
    create table :group_collection_branches do |t|
      t.belongs_to :parent
      t.belongs_to :child
    end
    add_index :group_collection_branches, :parent
    add_index :group_collection_branches, :child
    
  end

  def self.down
    remove_index :group_collections, :name
    remove_index :group_collections, :permalink
    remove_index :group_collections, :user_id
    drop_table :group_collections
    
    remove_index :product_groupings, :group_collection
    remove_index :product_groupings, :product_group
    drop_table :product_groupings
    
    remove_index :group_collection_branches, :parent
    remove_index :group_collection_branches, :child
    drop_table :group_collection_branches
  end
end
