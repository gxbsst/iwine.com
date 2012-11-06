class AddDeletedAtToWineDetails < ActiveRecord::Migration
  def change
    add_column :wine_details, :deleted_at, :datetime, :default => nil
  end
end
