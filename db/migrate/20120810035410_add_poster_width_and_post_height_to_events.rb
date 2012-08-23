class AddPosterWidthAndPostHeightToEvents < ActiveRecord::Migration
  def change
    add_column :events, :poster_width, :integer
    add_column :events, :poster_height, :integer
  end
end
