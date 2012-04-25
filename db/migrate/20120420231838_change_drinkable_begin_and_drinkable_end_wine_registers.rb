class ChangeDrinkableBeginAndDrinkableEndWineRegisters < ActiveRecord::Migration
  def up
    change_column :wine_registers, :drinkable_begin, :int, :limit => 11
    change_column :wine_registers, :drinkable_end, :int, :limit => 11
  end

  def down
  end
end
