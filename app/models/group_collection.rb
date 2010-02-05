class GroupCollection < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :user
  
  has_many :product_groupings
  has_many :product_groups, :through => :product_groupings
  
  has_many :group_collection_branches, :foreign_key => :parent_id
  has_many :children, :through => :group_collection_branches, :source => :child
  
  before_save :set_permalink
  
  def self.from_url(url)
    return true
  end

  def products
    return true
  end
    
  def to_url
    return true
  end
  
  def set_permalink
    return true
  end
  
  def to_s
    "<GroupCollection#{id && "[#{id}]"}:'#{to_url}'>"
  end
end
