class ChangeIsNvTypeFromWineDetailsAndRegisters < ActiveRecord::Migration
  def up
    change_column(:wine_registers, :is_nv, :boolean, :default => false)
    change_column(:wine_details, :is_nv, :boolean, :default => false)
  end

  def down
    change_column :wine_details, :is_nv, :integer, :limit => 1, :default => 0
    change_column :wine_registers, :is_nv, :integer, :limit => 1, :default => 0
  end
end
