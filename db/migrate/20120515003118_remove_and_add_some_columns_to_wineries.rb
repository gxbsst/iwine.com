class RemoveAndAddSomeColumnsToWineries < ActiveRecord::Migration
  def up
    add_column :wineries, :logo, :string, :limit => 100
    add_column :wineries, :address, :string, :limit => 100
    add_column :wineries, :official_site, :string, :limit => 100
    add_column :wineries, :email, :string, :limit => 50
    add_column :wineries, :cellphone, :string, :limit => 50
    add_column :wineries, :fax, :string, :limit => 50
    add_column :wineries, :config, :string

    remove_column :wineries, :region_id
    remove_column :wineries, :winemaker
    remove_column :wineries, :history
    remove_column :wineries, :legend
    remove_column :wineries, :environment
    remove_column :wineries, :multiple
    remove_column :wineries, :badge
  end

  def down
    remove_column :wineries, :logo
    remove_column :wineries, :address
    remove_column :wineries, :official_site
    remove_column :wineries, :email
    remove_column :wineries, :cellphone
    remove_column :wineries, :fax
    remove_column :wineries, :config

    add_column :wineries, :winemaker, :string, :limit => 100
    add_column :wineries, :history, :text
    add_column :wineries, :legend, :text
    add_column :wineries, :environment, :text
    add_column :wineries, :multiple, :text
    add_column :wineries, :badge, :text
  end
end
