class Inventory < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 255 }

  scope :confirmed, -> { InventoryUser.confirmed }
  scope :pending, -> { InventoryUser.pending }

  has_many :inventory_users
  has_many :users, through: :inventory_users
  has_many :admins, -> { admin }, source: :user, through: :inventory_users
  has_many :writers, -> { write }, source: :user, through: :inventory_users
  has_many :readers, -> { read }, source: :user, through: :inventory_users
  has_many :invited_users, -> { invited }, source: :user, through: :inventory_users
  belongs_to :owner, polymorphic: true
end
