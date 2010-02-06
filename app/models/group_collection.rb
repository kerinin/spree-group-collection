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

  def self.parse_globs( c_glob, pg_glob )
    children = c_glob.nil? ? [] : c_glob.split('+')
    product_groups = pg_glob.nil? ? [] : pg_glob.split('+')

    # NOTE: this will fail silently if a requested name isn't found
    children.map!{|permalink| child = GroupCollection.find_by_permalink(permalink); child ? child : nil }.compact! unless children.nil?
    product_groups.map!{|permalink| pg = ProductGroup.find_by_permalink(permalink); pg ? pg : nil }.compact! unless product_groups.nil?

    [ children, product_groups ]
  end

  def self.from_glob( glob )
    if glob.count > 1
      c_glob, pg_glob = glob
    else
      c_glob, pg_glob = glob[0], nil
    end

    children, product_groups = GroupCollection.parse_globs(c_glob, pg_glob)

    if product_groups.empty? && children.count == 1
      # In case GroupCollection#show came through the glob for some reason
      return children[0]
    else
      gc = GroupCollection.new()
      gc.children = children
      gc.product_groups = product_groups
      return gc
    end
  end

  def all_product_groups
    [ self.product_groups + self.children.map{ |gc| gc.all_product_groups } ].flatten.uniq
  end

  def to_url
    return true
  end

  def set_permalink
    self.permalink = GroupCollection.make_permalink(self.name, self.user)
  end

  def to_s
    "<GroupCollection#{id && "[#{id}]"}:'#{to_url}'>"
  end
end

