class Users::WineCellar < ActiveRecord::Base
  
  PRIVATE_TYPE_SECRET = 1
  PRIVATE_TYPE_FRIEND = 2
  PRIVATE_TYPE_USER = 3
  PRIVATE_TYPE_PUBLIC = 4
  
  include Users::UserSupport
  
  belongs_to :user
end
