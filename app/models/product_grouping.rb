class ProductGrouping < ActiveRecord::Base
  belongs_to :product_group
  belongs_to :group_collection
  
  validates_presence_of :product_group
  validates_presence_of :group_collection
end
