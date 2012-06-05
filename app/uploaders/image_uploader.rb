
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
    "uploads/#{model.class.to_s.underscore}/#{model.imageable_type.constantize.table_name}/#{model.imageable_id}"
  end
  
  def default_url
    "/assets/base/" + [version_name, "wine_default.jpg"].compact.join('_')
  end
  
  def md5
    var = :"@#{mounted_as}_md5"
    model.instance_variable_get(var) or model.instance_variable_set(var, ::Digest::MD5.file(current_path).hexdigest)
  end

  def filename
    model.read_attribute( :image ) || Digest::SHA1.hexdigest("#{Time.now.utc}--#{original_filename()}") + '.' + file.extension  if original_filename
  end

  def timestamp
    var = :"@#{mounted_as}_timestamp"
    model.instance_variable_get(var) or model.instance_variable_set(var, Time.now.to_i)
  end

  version :large do
    process :resize_to_limit => [APP_DATA["image"]["wine"]["large"]["width"], '']
  end
  
  version :middle, :from_version => :large do
    process :resize_to_limit => [APP_DATA["image"]["wine"]["middle"]["width"],'']
    process :store_geometry
  end

  #130
  version :thumb_x, :from_version => :large  do
    process :resize_to_fill => [APP_DATA["image"]["wine"]["x_thumb"]["width"],
                                APP_DATA["image"]["wine"]["x_thumb"]["height"]]
  end
  #100
  version :thumb, :from_version => :large  do
    process :resize_to_fill => [APP_DATA["image"]["wine"]["thumb"]["width"],
                                APP_DATA["image"]["wine"]["thumb"]["height"]]
  end
  
  # Winery
  version :middle_x, :from_version => :large, :if => :is_winery? do
    process :resize_to_limit => [APP_DATA["image"]["winery"]["middle_x"]["width"],'']
  end

  def should_process?
    @should_process ||= false
  end

  protected

  def is_crop? picture
    return false unless should_process?
    return model.crop_x.present?
  end

  def is_wine? picture
    return false unless should_process?
    model.imageable_type == "Wines::Detail"
  end

  def is_winery? picture
    model.imageable_type == "Winery"
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
        Photo.update_all("width = #{img[:width]}, height = #{img[:height]} ", "id = '#{model.id}'")
      end
      img = yield(img) if block_given?
      img
    end
  end
  
end
