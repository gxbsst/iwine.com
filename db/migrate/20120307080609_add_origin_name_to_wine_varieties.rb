class AddOriginNameToWineVarieties < ActiveRecord::Migration
  def change
    add_column :wine_varieties, :origin_name, :string
    
  end
end
