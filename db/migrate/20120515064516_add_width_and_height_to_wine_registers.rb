class AddWidthAndHeightToWineRegisters < ActiveRecord::Migration
  def change
    add_column :wine_registers, :width, :integer

    add_column :wine_registers, :height, :integer

  end
end
