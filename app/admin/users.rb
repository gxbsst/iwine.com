ActiveAdmin.register User do
  
  actions :index, :show

  scope :all, :default => true
  scope :active_user
  
  filter :email
  filter :username
  filter :id

  index do
    column(:id) {|user| link_to user.id, admin_user_path(user)}
    column :username
    column :email
  end

end
