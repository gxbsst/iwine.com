class AddCommentsCountToEvents < ActiveRecord::Migration
  def change
    add_column :events, :comments_count, :integer
  end
end
