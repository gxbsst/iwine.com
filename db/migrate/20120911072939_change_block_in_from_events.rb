class ChangeBlockInFromEvents < ActiveRecord::Migration
  def up
    change_column(:events, :block_in, :integer,  :null => true, :default => nil)
  end

  def down
    change_column(:events, :block_in, :integer, :default=> 0, :null => false)
  end
end
