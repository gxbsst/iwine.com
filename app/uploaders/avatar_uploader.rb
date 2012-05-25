# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  permissions 0777

  # Include RMagick or MiniMagick support:

  # include CarrierWave::RMagick

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
  
  # process :get_geometry
  # def geometry
  #     @geometry
  # end
  # 
  # def get_geometry
  #     # binding.pry
  #     if (@file)
  #       
  #         img = ::MiniMagick::Image.open(@file.file)
  #         @geometry = [ img[:width], img[:height] ]
  #     end
  # end
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
  version :origin do
    resize_to_limit(APP_DATA["image"]["user"]["origin"]["width"],  APP_DATA["image"]["user"]["origin"]["height"])
  end

  version :large do
    process :crop
    resize_to_limit(APP_DATA["image"]["user"]["large"]["width"],APP_DATA["image"]["user"]["large"]["height"])
  end

  version :middle do
    resize_to_limit( APP_DATA["image"]["user"]["middle"]["width"],  APP_DATA["image"]["user"]["middle"]["height"])
  end

  version :thumb do
    resize_to_limit( APP_DATA["image"]["user"]["thumb"]["width"],  APP_DATA["image"]["user"]["thumb"]["height"])
  end
  
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

  def filename
    model.read_attribute( :avatar ) || Digest::SHA1.hexdigest("#{Time.now.utc}--#{original_filename()}") + '.png'
  end

  def crop
    if model.crop_x.present?
      resize_to_limit(APP_DATA["image"]["user"]["origin"]["width"],  APP_DATA["image"]["user"]["origin"]["height"])

      manipulate! do |img|
        x = model.crop_x
        y = model.crop_y
        w = model.crop_w
        h = model.crop_h

        # img.crop!(x, y, w, h)
        # crop_params = "#{w}x#{h}+#{x}+#{y}"
        # binding.pry
        # img.crop(crop_params)
        w << 'x' << h << '+' << x << '+' << y
        img.crop(w)
         # img.strip
        # model.avatar.recreate_versions!
        img
      end

    end # end if

  end


end
