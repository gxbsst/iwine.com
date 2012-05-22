class AddCountsToWineriesAndPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :counts, :string, :limit => 50
    add_column :wines, :counts, :string, :limit => 50
    add_column :wineries, :counts, :string, :limit => 50
    add_column :users, :counts, :string, :limit => 50

  end
end
