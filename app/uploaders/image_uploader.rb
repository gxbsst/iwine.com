# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  attr_accessor :should_process


  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
   include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{OWNER_TYPES[model.owner_type]}/#{model.business_id}"

  #  "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  def default_url
    "/assets/base/" + [version_name, "wine_default.jpg"].compact.join('_')
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  def md5
    var = :"@#{mounted_as}_md5"
    model.instance_variable_get(var) or model.instance_variable_set(var, ::Digest::MD5.file(current_path).hexdigest)
  end

  def filename
    model.read_attribute( :image ) || Digest::SHA1.hexdigest("#{Time.now.utc}--#{original_filename()}") + '.' + file.extension
  end
  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  #def filename

    #@name ||= "#{timestamp}-#{super}.jpg" if original_filename.present? and super.present?
    #@name ||= "#{timestamp}.jpg" if original_filename.present? and super.present?
    #@name ||= "#{secure_token}.#{file.extension}" if original_filename.present?
#  end

  def timestamp
    var = :"@#{mounted_as}_timestamp"
    model.instance_variable_get(var) or model.instance_variable_set(var, Time.now.to_i)
  end

  #version :user do
  #  version :user_thumb
  #  version :user_large
  #end

  version :large, :if => :is_user? do
    resize_to_limit(600, 600)
  end

  version :normal, :if => :is_user? do
    resize_to_limit(190, 190)
  end
#  ## USER

  version :thumb, :if => :is_user? do
    resize_to_limit(100, 100)
  end

  version :avatar, :if => :is_crop? do
    process :crop
  end

  # version :large, :if => :is_user?  do
  #  resize_to_limit(200, 200)
  #end
  #
  #version :avatar, :if => :is_crop? do
  #  process :crop
  #  #resize_to_fill(200, 200)
  #end

  #  version :large, :if => :is_user? do
  #    process :resize_to_limit => [200, 200]
  #  end

  ## WINE
  version :w_thumb_x, :if => :is_wine?  do
    process :resize_to_limit => [APP_DATA["image"]["wine"]["x_thumb"]["width"],
                                 APP_DATA["image"]["wine"]["x_thumb"]["height"]]
  end
  
  version :w_thumb, :if => :is_wine?  do
    process :resize_to_limit => [APP_DATA["image"]["wine"]["thumb"]["width"],
                                 APP_DATA["image"]["wine"]["thumb"]["height"]]
  end
  
  version :w_middle, :if => :is_wine? do
    process :resize_to_limit => [APP_DATA["image"]["wine"]["middle"]["width"],
                                 APP_DATA["image"]["wine"]["middle"]["height"]]
    process :store_geometry
  end

  version :w_large, :if => :is_wine? do
    process :resize_to_limit => [APP_DATA["image"]["wine"]["large"]["width"],
                                 APP_DATA["image"]["wine"]["large"]["height"] ]
  end

  ## WINERY
  version :wy_thumb_x, :if => :is_winery?  do
    process :resize_to_limit => [APP_DATA["image"]["winery"]["x_thumb"]["width"], 
                                 APP_DATA["image"]["winery"]["x_thumb"]["height"]]
  end
  
  version :wy_thumb, :if => :is_winery?  do
    process :resize_to_limit => [APP_DATA["image"]["winery"]["thumb"]["width"], 
                                 APP_DATA["image"]["winery"]["thumb"]["height"]]
  end
  
  version :wy_middle, :if => :is_winery? do
    process :resize_to_limit => [APP_DATA["image"]["winery"]["middle"]["width"], 
                                 '']
    process :store_geometry
    
  end

  version :wy_large, :if => :is_winery? do
    process :resize_to_limit => [APP_DATA["image"]["winery"]["large"]["width"], 
                                 APP_DATA["image"]["winery"]["large"]["height"]]
  end

  def should_process?
    @should_process ||= false
  end

  def crop
    manipulate! do |img|
      x = model.crop_x.to_i
      y = model.crop_y.to_i
      w = model.crop_w.to_i
      h = model.crop_h.to_i
      img.crop!(x, y, w, h)
    end
  end

  #
  #version :user_small, :if => :is_user? do
  #  process :resize_to_limit => [100, 100]
  #end

  protected

  def is_crop? picture
    return false unless should_process?
    return model.crop_x.present?
  end

  def is_user? picture
    return false unless should_process?
    model.owner_type == OWNER_TYPE_USER
  end

  def is_wine? picture
    return false unless should_process?
    model.owner_type == OWNER_TYPE_WINE
  end

  def is_winery? picture
    model.owner_type == OWNER_TYPE_WINERY
  end

  #def secure_token
  #  var = :"@#{mounted_as}_secure_token"
  #  model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  #end
  def secure_token
    ivar = "@#{mounted_as}_secure_token"
    token = model.instance_variable_get(ivar)
    token ||= model.instance_variable_set(ivar,ActiveSupport::SecureRandom.hex(4))
  end
  
  # 保存图片的大小到数据库
  def store_geometry
    manipulate! do |img|
      if model
        model.width = img[:width]
        model.height = img[:height]
      end
      img = yield(img) if block_given?
      img
    end
  end
  
end
