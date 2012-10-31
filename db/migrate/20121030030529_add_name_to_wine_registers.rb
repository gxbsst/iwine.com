class AddNameToWineRegisters < ActiveRecord::Migration
  def change
    add_column :wine_registers, :winery_name_zh, :string
    add_column :wine_registers, :winery_name_en, :string
    add_column :wine_registers, :winery_origin_name, :string
  end
end
