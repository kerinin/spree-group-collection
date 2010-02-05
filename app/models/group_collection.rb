class GroupCollection < ActiveRecord::Base
  validates_presence_of :name

  before_save :set_permalink
  
  has_many :groups, :through => :product_groupings
  has_many :children, :through => :group_collection_branches, :as => :parent
  
  def from_url
  end

  def products
  end
    
  def to_url
  end
  
  def set_permalink
  end
  
  def to_s
    "<GroupCollection#{id && "[#{id}]"}:'#{to_url}'>"
  end
end
