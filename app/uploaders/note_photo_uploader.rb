# encoding: utf-8

class NotePhotoUploader < CarrierWave::Uploader::Base
  permissions 0777
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  #800*800
  version :origin do
    resize_to_limit(APP_DATA["image"]["note"]["origin"]["width"],  APP_DATA["image"]["note"]["origin"]["height"])
  end
  #600*600
  version :large do
    process :crop
    resize_to_limit(APP_DATA["image"]["note"]["large"]["width"],APP_DATA["image"]["note"]["large"]["height"])
  end
  #200*200
  version :middle_x do
    resize_to_limit( APP_DATA["image"]["note"]["middle_x"]["width"],  APP_DATA["image"]["note"]["middle_x"]["height"])
  end

  # 100*100
  version :middle do
    resize_to_limit( APP_DATA["image"]["note"]["middle"]["width"],  APP_DATA["image"]["note"]["middle"]["height"])
  end
  #70*70
  version :thumb do
    resize_to_limit( APP_DATA["image"]["note"]["thumb"]["width"],  APP_DATA["image"]["note"]["thumb"]["height"])
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
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

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    model.read_attribute( :photo ) || Digest::SHA1.hexdigest("#{Time.now.utc}--#{original_filename()}") + '.png' if original_filename
  end

  #TODO 更改尺寸数据
  def crop
    if model.crop_x.present?
      resize_to_limit(APP_DATA["image"]["note"]["origin"]["width"],  APP_DATA["image"]["note"]["origin"]["height"])
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

end
