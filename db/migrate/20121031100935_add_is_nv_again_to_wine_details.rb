class AddIsNvAgainToWineDetails < ActiveRecord::Migration
  def change
    add_column :wine_details, :is_nv, :boolean, :default => false
  end
end
