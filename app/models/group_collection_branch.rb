class GroupCollectionBranch < ActiveRecord::Base
  belongs_to :parent, :class_name => "GroupCollection"
  belongs_to :child, :class_name => "GroupCollection"

  validates_presence_of :parent
  validates_presence_of :child
end

