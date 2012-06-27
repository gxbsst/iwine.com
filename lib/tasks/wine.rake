namespace :wine do

  desc "Init photos_count of Wine"
  task :init_photos_count => :environment do
  	wines = Wine.where(:photos_count => 0)
  	wines.each do |wine|
  		wine.update_attribute(:photos_count, wine.photos.count)
  	end
  end

  desc "Init _count of Wine"
  task :init_photos_count => :environment do
  	wines = Wine.where(:photos_count => 0)
  	wines.each do |wine|
  		wine.update_attribute(:photos_count, wine.photos.count)
  	end
  end
end
