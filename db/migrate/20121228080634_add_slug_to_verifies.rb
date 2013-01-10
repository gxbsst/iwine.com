class AddSlugToVerifies < ActiveRecord::Migration
  def change
    add_column :verifies, :slug, :string, :limit => 64
    add_index  :verifies, :slug
  end
end
