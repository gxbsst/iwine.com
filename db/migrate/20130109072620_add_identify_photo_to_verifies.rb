class AddIdentifyPhotoToVerifies < ActiveRecord::Migration
  def change
    add_column :verifies, :identify_photo, :string
  end
end
