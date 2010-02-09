class CreateGroupCollection < ActiveRecord::Migration
  def self.up
    add_column :product_groups, :user_id, :integer
    add_index :product_groups, :user_id

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

    create_table :collecteds do |g|
      g.belongs_to :group_collection
      g.belongs_to :group, :polymorphic => true
    end
    add_index :collecteds, :group_id
    add_index :collecteds, :group_type
    add_index :collecteds, :group_collection_id
  end

  def self.down
    remove_index :product_groups, :user_id
    remove_column :product_groups, :user_id

    remove_index :group_collections, :name
    remove_index :group_collections, :permalink
    remove_index :group_collections, :user_id
    drop_table :group_collections

    remove_index :collecteds, :group_collection_id
    remove_index :collecteds, :group_id
    remove_index :collecteds, :group_type
    drop_table :collecteds
  end
end

