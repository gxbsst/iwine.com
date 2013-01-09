class CreateVerifies < ActiveRecord::Migration
  def change
    create_table :verifies do |t|
      t.references :user
      t.string :varify_type
      t.string :trade_type
      t.string :indentify_card
      t.text :description
      t.string :image
      t.integer :audit_log_id
      t.integer :audit_log_result
      t.timestamps
    end
    add_index :verifies, :user_id
  end
end
