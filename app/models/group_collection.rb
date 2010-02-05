class GroupCollection < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :user
  
  has_many :product_groupings
  has_many :product_groups, :through => :product_groupings
  
  has_many :group_collection_branches, :foreign_key => :parent_id
  has_many :children, :through => :group_collection_branches, :source => :child
  
  before_save :set_permalink
  
  def to_param
    return self.permalink
  end
  
  def self.from_url(url)
    gc = nil;
    case url
      when /\/c\/(.+?)\/(.+)\//, /\/c\/(.+?)\/(.+)$/
        # /c/col1/group1/
        # /c/col1/group1
        # /c/col1+col2/group1+groupt2/
        # /c/col1+col2/group1+groupt2
        a,b = $1, $2
        children, product_groups = a.split('+'), b.split('+')
        # NOTE: This is really fucking ugly, but splitting $1 seems to reset $2
      when /\/c\/\/(.+?)\/$/, /\/c\/\/(.+)$/
        # /c//group1/
        # /c//group1
        # /c//group1+group2/
        # /c//group1+group2
        product_groups = $1.split('+')
      when /\/c\/(.+?)\//, /\/c\/(.+)$/
        # /c/col1+col2/
        # /c/col1+col2
        children = $1.split('+') 
      else
        return(nil)
    end
    
    if product_groups.nil? && children.count == 1
      gc = GroupCollection.find_by_name( children[0] )
    else
      # NOTE: this will fail silently if a requested name isn't found
      children.map!{|permalink| child = GroupCollection.find_by_permalink(permalink); child ? child : nil }.compact! unless children.nil?
      product_groups.map!{|permalink| pg = ProductGroup.find_by_permalink(permalink); pg ? pg : nil }.compact! unless product_groups.nil?
      
      gc = GroupCollection.new()
      gc.children = children unless children.nil?
      gc.product_groups = product_groups unless product_groups.nil?
    end
    
    gc
  end

  def products
    return true
  end
    
  def to_url
    return true
  end
  
  def set_permalink
    self.permalink = self.name.to_url
  end
  
  def to_s
    "<GroupCollection#{id && "[#{id}]"}:'#{to_url}'>"
  end
end
