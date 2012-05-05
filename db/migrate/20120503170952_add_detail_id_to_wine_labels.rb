class AddDetailIdToWineLabels < ActiveRecord::Migration
  def change
    add_column :wine_labels, :detail_id, :integer

  end
end
