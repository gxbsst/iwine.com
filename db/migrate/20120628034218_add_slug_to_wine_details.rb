class AddSlugToWineDetails < ActiveRecord::Migration
  def change
    add_column :wine_details, :slug, :string, :limit => 128
    # add_index :wine_details, :slug
  end
end
