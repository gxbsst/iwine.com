class RenameVarifyTypeFromVerifies < ActiveRecord::Migration
  def change
    rename_column :verifies, :varify_type, :verify_type
  end
end
