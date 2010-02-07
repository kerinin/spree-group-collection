class GroupCollection < ActiveRecord::Base
  require "stringex"

  validates_presence_of :name
  validates_uniqueness_of :permalink, :allow_nil => true, :allow_blank => true

  belongs_to :user

  has_many :product_groupings, :dependent => :destroy
  has_many :product_groups, :through => :product_groupings

  has_many :group_collection_branches, :foreign_key => :parent_id, :dependent => :destroy
  has_many :children, :through => :group_collection_branches, :source => :child

  before_save :set_permalink

  make_permalink :with => :permalink

  def to_param
    return self.permalink
  end

  def self.make_permalink(name,user=nil)
    "#{name.to_url}#{user.id unless user.nil?}"
  end

  def all_product_groups
    [ self.product_groups + self.children.map{ |gc| gc.all_product_groups } ].flatten.uniq
  end

  def to_url
    return self.permalink unless permalink.nil?
  end

  def set_permalink
    self.permalink = GroupCollection.make_permalink(self.name, self.user)
  end

  def to_s
    "<GroupCollection#{id && "[#{id}]"}:'#{self.name}'>"
  end
end

