class AddIsNvToWineDetails < ActiveRecord::Migration
  def change
    add_column :wine_details, :is_nv, :integer, :limit => 1, :default => 0
    add_column :wine_registers, :is_nv, :integer, :limit => 1, :default => 0

  end
end
