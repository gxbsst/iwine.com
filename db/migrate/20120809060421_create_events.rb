# encoding: utf-8
class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.belongs_to :user
      t.string :poster
      t.string :title
      t.text :description
      t.datetime :begin_at
      t.datetime :end_at
      t.integer :block_in, :default => 0, :null => false
      t.belongs_to :region, :null => false
      t.string :address, :null => false
      t.string :longitude
      t.string :latitude
      t.belongs_to :audit_log
      t.integer :pulish_status, :default => 1 # 1 => 草稿, 2 => 已经发布, 0 => 取消
      t.integer :followers_count, :default => 0
      t.integer :participants_count, :default => 0

      t.timestamps
    end
    add_index :events, :user_id
    add_index :events, :region_id
    add_index :events, :audit_log_id
  end
end
