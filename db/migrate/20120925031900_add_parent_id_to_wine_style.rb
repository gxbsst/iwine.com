class AddParentIdToWineStyle < ActiveRecord::Migration
  def change
    add_column :wine_styles, :parent_id, :integer, :default => nil
  end
end
