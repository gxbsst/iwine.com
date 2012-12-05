class UserSnsFriends < ActiveRecord::Base
  attr_accessible :avatar, :name, :nickname, :type, :uid
end
