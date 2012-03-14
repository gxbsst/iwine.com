class CreateTableSettings < ActiveRecord::Migration
  def up
    create_table :settings, :force => true do |t|
      t.string :name # 设置名
      t.string :value # 设置值
      t.integer :user_id
      t.timestamps
    end
  end

  def down
    drop_table :settings
  end
end