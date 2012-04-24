class ChangeVintageWineRegister < ActiveRecord::Migration
  def up
    change_column :wine_registers, :drinkable_begin, :datetime
    change_column :wine_registers, :drinkable_end, :datetime
    change_column :wine_registers, :vintage, :datetime

    change_column :wine_details, :drinkable_begin, :datetime
    change_column :wine_details, :drinkable_end, :datetime
    change_column :wine_details, :year, :datetime
  end

  def down
  end
end
