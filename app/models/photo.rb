class Photo < ActiveRecord::Base

  belongs_to :user

  mount_uploader :raw_name, ImageUploader

  ## FIXED
  ## 修改image_uploader.rb 中 is_user? 的model的数据为空的bugs

  after_save :recreate_delayed_versions!

  def recreate_delayed_versions!
    raw_name.should_process = true
    raw_name.recreate_versions!
  end

end
