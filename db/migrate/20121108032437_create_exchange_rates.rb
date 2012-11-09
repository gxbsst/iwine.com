class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table :exchange_rates do |t|
      t.string :name_en
      t.string :name_zh
      t.float :rate

      t.timestamps
    end
  end
end
