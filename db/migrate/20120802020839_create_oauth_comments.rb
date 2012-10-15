class CreateOauthComments < ActiveRecord::Migration
  def change
    create_table :oauth_comments do |t|
      t.integer :comment_id
      t.string :sns_type, :limit => "20"
      t.string :sns_id, :limit => "255"

      t.timestamps
    end
  end
end
