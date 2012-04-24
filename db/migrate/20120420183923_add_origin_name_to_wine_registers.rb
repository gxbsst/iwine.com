class AddOriginNameToWineRegisters < ActiveRecord::Migration
  def change
    add_column :wine_registers, :origin_name, :string, :limit => 45
  end
end
