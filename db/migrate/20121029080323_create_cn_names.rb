class CreateCnNames < ActiveRecord::Migration
  def up
    create_table :cn_names do |t|
      t.references :nameable, :polymorphic => true
      t.references :user
      t.string :name_zh
    end
  end

  def down
    drop_table :cn_names
  end
end
