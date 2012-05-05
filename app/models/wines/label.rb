class Wines::Label < ActiveRecord::Base
  include Wines::WineSupport
  belongs_to :detail

  mount_uploader :filename, WineLabelUploader
end
