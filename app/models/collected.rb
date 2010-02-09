class Collected < ActiveRecord::Base
  belongs_to :group_collection
  belongs_to :group, :polymorphic => true

  validates_presence_of :group_collection
  validates_presence_of :group
end

