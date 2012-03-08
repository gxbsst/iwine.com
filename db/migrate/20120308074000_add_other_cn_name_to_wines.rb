class AddOtherCnNameToWines < ActiveRecord::Migration
  def change
    add_column :wines, :other_cn_name, :string

  end
end
