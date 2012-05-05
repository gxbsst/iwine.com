class AddPointToComments < ActiveRecord::Migration
  def change
    add_column :comments, :point, :integer
    add_column :comments, :private, :integer, :default => 1 # 所有人可见， 请参看data.yml
    add_column :comments, :is_share, :boolean, :default => true # 默认为广播
    add_column :comments, :_config, :text # 主要保存分享到新浪等信息
  end
end
