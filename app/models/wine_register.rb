class WineRegister < ActiveRecord::Base
  # upload photo
  mount_uploader :photo_name, WineRegisterUploader
  serialize [:variety_percentage, :variety_name]
end
