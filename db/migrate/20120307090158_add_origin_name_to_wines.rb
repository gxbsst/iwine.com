class AddOriginNameToWines < ActiveRecord::Migration
  def change
    add_column :wines, :origin_name, :string
  end
end
