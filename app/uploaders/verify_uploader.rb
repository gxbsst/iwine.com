# encoding: utf-8

class VerifyUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.slug}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # "/assets/base/" + [version_name, "user_default.jpg"].compact.join('_')
    "/assets/userpic.jpg"
  end

    version :origin do
    resize_to_limit(APP_DATA["image"]["poster"]["origin"]["width"], 
                    APP_DATA["image"]["poster"]["origin"]["height"])
  end

  def filename
    if original_filename
      model.read_attribute( :image) || 
        Digest::SHA1.hexdigest("#{Time.now.utc}--#{original_filename()}") + '.png'
    end
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

end

