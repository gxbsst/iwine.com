
# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
   include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:

  # CarrierWave::MiniMagick api http://rdoc.info:8080/github/jnicklas/carrierwave/master/CarrierWave/MiniMagick
  # resize_to_fill(width, height, gravity = 'Center'): 如果图片大于给定尺寸，截取图片（gravity）指定位置部分图片，然后进行缩放.
  # resize_and_pad(width, height, background = :transparent, gravity = 'Center'):同 fill 但是会在空白部分填充颜色
  # resize_to_fit(width, height): 处理所有大小的图片， 处理后的图片可能比给定尺寸窄或者短
  # resize_to_limit(width, height): 如果图片比给定尺寸大就进行处理， 处理后的图片可能比给定尺寸窄或者短
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

  #610*640
  version :large_x do
    process :resize_to_fit => [APP_DATA["image"]["wine"]["large_x"]["width"],
                               APP_DATA["image"]["wine"]["large_x"]["height"]]
  end

  version :large, :from_version => :large_x do
    process :resize_to_fit => [APP_DATA["image"]["wine"]["large"]["width"],
                               APP_DATA["image"]["wine"]["large"]["height"]]
  end

  # Winery360*330
  version :middle_x, :from_version => :large, :if => :is_winery? do
    process :resize_to_fit => [APP_DATA["image"]["winery"]["middle_x"]["width"],
                              APP_DATA["image"]["winery"]["middle_x"]["height"]]
  end
  
  #200*440
  version :middle, :from_version => :large do
    process :resize_to_fit => [APP_DATA["image"]["wine"]["middle"]["width"],
                               APP_DATA["image"]["wine"]["middle"]["height"]]
   # process :store_geometry
    process :get_geometry
    def geometry
      @geometry
    end
  end
  #190*190 for album list
  version :x_middle, :if => :has_album? do
    process :resize_to_fit => [APP_DATA["image"]["album"]["x_middle"]["width"],
                               APP_DATA["image"]["album"]["x_middle"]["height"]]
  end

  #150*150 for album cover
  version :xx_middle, :if => :has_album? do
    process :resize_to_fit => [APP_DATA["image"]["album"]["xx_middle"]["width"],
                               APP_DATA["image"]["album"]["xx_middle"]["height"]]
  end

  #100*100
  version :thumb_x, :from_version => :large do
    process :resize_to_fill => [APP_DATA["image"]["wine"]["x_thumb"]["width"],
                                APP_DATA["image"]["wine"]["x_thumb"]["height"]]
  end

  #130*130
  version :thumb, :from_version => :large do
    process :resize_to_fill => [APP_DATA["image"]["wine"]["thumb"]["width"],
                                APP_DATA["image"]["wine"]["thumb"]["height"]]
  end


  protected
  
  def get_geometry
    @geometry = {} 
    manipulate! do |img|
     @geometry[:width] = img[:width] 
     @geometry[:height] = img[:height] 
     return @geometry
    end
  end

  def is_winery? picture
    model.imageable_type == "Winery"
  end
  
  #判断一张图片是否有指定相册
  def has_album? picture
    model.album_id.to_i != -1
  end

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
