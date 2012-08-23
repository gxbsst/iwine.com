# encoding: utf-8

class PosterUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # "/assets/base/" + [version_name, "user_default.jpg"].compact.join('_')
    "/assets/userpic.jpg"
  end

    version :origin do
    resize_to_limit(APP_DATA["image"]["poster"]["origin"]["width"], 
                    APP_DATA["image"]["user"]["origin"]["height"])
  end

  version :large do
    process :crop
    resize_to_limit(APP_DATA["image"]["poster"]["large"]["width"],
                    APP_DATA["image"]["poster"]["large"]["height"])

    process :get_geometry
    def geometry
      @geometry
    end
  end

  # 50
  version :middle, :from_version => :large do
    resize_to_limit(APP_DATA["image"]["poster"]["middle"]["width"], 
                    APP_DATA["image"]["poster"]["middle"]["height"])
  end

  version :thumb, :from_version => :large do
    resize_to_limit(APP_DATA["image"]["poster"]["thumb"]["width"],  
                    APP_DATA["image"]["poster"]["thumb"]["height"])
  end

  def filename
    if original_filename
      model.read_attribute( :poster ) || 
        Digest::SHA1.hexdigest("#{Time.now.utc}--#{original_filename()}") + '.png'
    end
  end

  def crop
    if model.crop_x.present?
      resize_to_limit(APP_DATA["image"]["poster"]["origin"]["width"], 
                      APP_DATA["image"]["poster"]["origin"]["height"])
      manipulate! do |img|
        x = model.crop_x
        y = model.crop_y
        w = model.crop_w
        h = model.crop_h
        w << 'x' << h << '+' << x << '+' << y
        img.crop(w)
        img
      end
    end # end if
  end

  protected
  def get_geometry
    @geometry = {} 
    manipulate! do |img|
      @geometry[:poster_width] = img[:width] 
      @geometry[:poster_height] = img[:height] 
      return @geometry
    end
  end


end
