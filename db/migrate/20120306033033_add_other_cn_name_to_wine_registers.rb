class AddOtherCnNameToWineRegisters < ActiveRecord::Migration
  def change
    add_column :wine_registers, :other_cn_name, :string

  end
end
