# encoding: utf-8
module VerifyUploader
  class Base < ::CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    # Choose what kind of storage to use for this uploader:
    storage :file
    # storage :fog

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "#{VerifyForm::VERIFY_PHOTO_PATH}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.slug}"
    end

    # Provide a default URL as a default if there hasn't been a file uploaded:
    def default_url
      # "/assets/base/" + [version_name, "user_default.jpg"].compact.join('_')
      "/assets/userpic.jpg"
    end



    def extension_white_list
      %w(jpg jpeg gif png)
    end

  end

  class Vocation < Base
    version :thumb do
      process :resize_to_limit => [APP_DATA["image"]["poster"]["origin"]["width"],
                                 APP_DATA["image"]["poster"]["origin"]["height"]]
    end

    def filename
      model.read_attribute( :vocation_photo ) || Digest::SHA1.hexdigest("#{Time.now.utc}--#{original_filename()}") + '.png' if original_filename
    end

  end

  class Identify < Base
    version :thumb do
      process :resize_to_limit => [APP_DATA["image"]["poster"]["origin"]["width"],
                                 APP_DATA["image"]["poster"]["origin"]["height"]]
    end
    def filename
      model.read_attribute( :identify_photo ) || Digest::SHA1.hexdigest("#{Time.now.utc}--#{original_filename()}") + '.png' if original_filename
    end

  end

end


