class AddStateToVerifies < ActiveRecord::Migration
  def change
    add_column :verifies, :state, :string
  end
end
