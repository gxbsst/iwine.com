# encoding: utf-8
FactoryGirl.define do
	
	factory :photo_with_album, :class => "Photo" do
		valid_file = File.new(File.join(Rails.root, 'spec', 'support', 'rails.png'))
		audit_status 0
		image File.open(valid_file)
		imageable {|c| c.association(:album)}
		user {|c| c.association(:user)}
		album {|c| c.association(:album)}
	end
end