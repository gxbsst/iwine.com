class AddIsNvToWines < ActiveRecord::Migration
  def change
    add_column :wines, :is_nv, :boolean, :default => false
  end
end
