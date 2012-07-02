# encoding: utf-8
FactoryGirl.define do
	factory :album_with_photo, :parent => :album do |p|
	  p.photos {|m|[m.association(:photo), m.association(:photo)]}
	end

	# factory :photo_with_audit_log, :parent => :photo, :class => Photo do |p|
	#   p.audit_logs {|p| [p.association(:audit_log),p.association(:audit_log)]}
	# end
end