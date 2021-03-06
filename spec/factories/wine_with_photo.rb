# encoding: utf-8
FactoryGirl.define do
	 factory :wine_with_photo, :parent => :wine do |w|
    # valid_file = File.new(File.join(Rails.root, 'spec', 'support', 'rails.png'))
    # images {
    #   [
    #     ActionController::TestUploadedFile.new(valid_file, Mime::Type.new('application/png'))
    #   ]
    # }
    w.photos {|p|[p.association(:photo_with_wine),
                  p.association(:photo_with_wine)]}
  end
end