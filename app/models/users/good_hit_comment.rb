class Users::GoodHitComment < ActiveRecord::Base
  include Users::UserSupport
  belongs_to :comment, :class_name => 'Wines::Comment'

end
