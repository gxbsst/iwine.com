class CreateInfoItems < ActiveRecord::Migration
  def up
    create_table :info_items do |t|
      t.string :title
      t.text :description
      t.references :winery
      t.timestamps
    end
  end

  def down
    drop_table :info_items
  end
end
