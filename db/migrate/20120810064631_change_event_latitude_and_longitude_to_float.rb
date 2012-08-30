class ChangeEventLatitudeAndLongitudeToFloat < ActiveRecord::Migration
  def up
    change_column :events, :longitude, :float
    change_column :events, :latitude, :float
  end

  def down
    change_column :events, :longitude, :integer
    change_column :events, :latitude, :integer
  end
end
