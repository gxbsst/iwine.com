class AddOriginNameToWineries < ActiveRecord::Migration
  def change
    add_column :wineries, :origin_name, :string, :limit => 50

  end
end
