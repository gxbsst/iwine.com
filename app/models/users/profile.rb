class Users::Profile < ActiveRecord::Base
  include Users::UserSupport
  belongs_to :user
end
