class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 25 }

  scope :accepted, -> { InventoryUser.confirmed }
  scope :invited, -> { InventoryUser.pending }
  scope :admin, -> { accepted.where(inventory_users: { user_role: 'admin' }) }
  scope :write, -> { accepted.where(inventory_users: { user_role: 'write' }) }
  scope :read, -> { accepted.where(inventory_users: { user_role: 'read' }) }

  has_and_belongs_to_many :organizations
  has_many :inventory_users
  has_many :inventories, -> { confirmed }, through: :inventory_users
  has_many :pending_inventories, -> { pending }, source: :inventory, through: :inventory_users
  has_many :owned_inventories, class_name: 'Inventory', as: :owner
  has_many :owned_organizations, class_name: 'Organization', foreign_key: 'owner_id'

  def self.search(query)
    where('username ilike :q or email ilike :q', q: "%#{query}%").limit(5)
  end

  def inventory_access?(user_role, inventory)
    permission = 'admin' if inventory.admins.include?(self)
    permission = 'write' if inventory.writers.include?(self)
    permission = 'read' if inventory.readers.include?(self)

    return if permission.nil? || InventoryUser.user_roles[permission] < InventoryUser.user_roles[user_role]
    true
  end
end
