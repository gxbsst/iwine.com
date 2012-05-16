# encoding: utf-8

class WineLabelUploader < CarrierWave::Uploader::Base
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

  def filename
    model.read_attribute( :filename ) || Digest::SHA1.hexdigest("#{Time.now.utc}--#{original_filename()}") + '.png'
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  
  def default_url
    "/assets/base/" + [version_name, "wine_label_default.jpg"].compact.join('_')
  end

  # Process files as they are uploaded:
  # process :scale => [400, 400]
  #process :resize_to_limit => [500, '']
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :large do
    process :resize_to_limit => [APP_DATA['image']['wine_label']['large']['width'], '']
  end

  version :thumb do
    process :resize_to_limit => [APP_DATA['image']['wine_label']['thumb']['width'], '']
  end

  version :middle do
    process :resize_to_limit => [APP_DATA['image']['wine_label']['middle']['width'], '']
    process :store
  end
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
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
