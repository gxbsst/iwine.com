class AddSlugToWineries < ActiveRecord::Migration
  def change
    add_column :wineries, :slug, :string, :limit => 128
    add_index  :wineries, :slug
  end
end
