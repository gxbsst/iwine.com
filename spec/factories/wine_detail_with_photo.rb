# encoding: utf-8
FactoryGirl.define do

	factory :wine_detail_with_photo, :parent => :wine_detail do |w|
    # valid_file = File.new(File.join(Rails.root, 'spec', 'support', 'rails.png'))
    # images {
    #   [
    #     ActionController::TestUploadedFile.new(valid_file, Mime::Type.new('application/png'))
    #   ]
    # }
    w.photos {|p|[p.association(:photo),
    	p.association(:photo)]}
    end
end