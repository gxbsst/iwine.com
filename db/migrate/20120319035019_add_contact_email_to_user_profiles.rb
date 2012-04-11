class AddContactEmailToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :contact_email, :string
  end
end
