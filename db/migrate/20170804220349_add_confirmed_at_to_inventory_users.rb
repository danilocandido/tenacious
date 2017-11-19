class AddConfirmedAtToInventoryUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :inventory_users, :confirmed_at, :datetime
  end
end
