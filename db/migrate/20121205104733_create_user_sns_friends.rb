class CreateUserSnsFriends < ActiveRecord::Migration
  def change
    create_table :user_sns_friends do |t|
      t.integer :user_id
      t.string :uid
      t.string :nickname
      t.string :name
      t.string :avatar
      t.string :type

      t.timestamps
    end
    add_index :user_sns_friends,  :user_id
    add_index :user_sns_friends,  :uid
    add_index :user_sns_friends,  :type

  end
end
