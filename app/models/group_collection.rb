class GroupCollection < ActiveRecord::Base
  require "stringex"
  acts_as_list :scope => 'user_id #{user_id ? (\'== \'+user_id.to_s ) : \'IS NULL\'}'
  default_scope :order => :position

  validates_presence_of :name
  validates_uniqueness_of :permalink, :allow_nil => true, :allow_blank => true

  belongs_to :user

  has_many :collecteds, :dependent => :destroy

  has_many :product_groups, :through => :collecteds, :source => :group, :source_type => "ProductGroup"
  has_many :children, :through => :collecteds, :source => :group, :source_type => "GroupCollection"

  before_save :set_permalink

  make_permalink :with => :permalink

  def to_param
    return self.permalink
  end

  def self.make_permalink(name,user=nil)
    "#{name.to_url}#{user.id unless user.nil?}"
  end

  def all_groups
    self.all_product_groups
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

