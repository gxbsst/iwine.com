class AddRegionNameToWineries < ActiveRecord::Migration
  def change
    add_column :wineries, :region_name, :string, :limit => 50

  end
end
