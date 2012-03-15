ActiveAdmin.register User do
  # index do
  #   column :email
  #   column :username
  #   column :remember_created_at
  #   column :sign_in_count
  #   column :current_sign_in_at
  #   column :last_sign_in_at
  #   column :role
  # end
  filter :email
  filter :username
end
