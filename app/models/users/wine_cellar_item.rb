class Users::WineCellarItem < ActiveRecord::Base
    include Users::UserSupport
    belongs_to :WineCellar
end
