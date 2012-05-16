class AddDescriptionToWineDetailsAndWineRegisters < ActiveRecord::Migration
  def change
    add_column :wine_details, :description, :text
    add_column :wine_registers, :description, :text
  end
end
