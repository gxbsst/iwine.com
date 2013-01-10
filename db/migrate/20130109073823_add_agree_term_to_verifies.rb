class AddAgreeTermToVerifies < ActiveRecord::Migration
  def change
    add_column :verifies, :agree_term, :boolean
  end
end
