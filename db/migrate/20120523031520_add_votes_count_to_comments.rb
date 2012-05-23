class AddVotesCountToComments < ActiveRecord::Migration
  def change
    add_column :comments, :votes_count, :integer, :limit => 11, :default => 0

  end
end
