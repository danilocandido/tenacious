class AddUsernameToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :username, :string, limit: 255

    User.all.each do |user|
      user.username = user.email
      user.save!
    end

    change_column :users, :username, :string, limit: 255, null: false
  end

  def down
    remove_column :users, :username
  end
end
