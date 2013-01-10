class FixIndentifyCard < ActiveRecord::Migration
  def change
    rename_column :verifies, :indentify_card, :identify_card
    rename_column :verifies, :image, :vocation_photo
  end
end
