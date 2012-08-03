namespace :wine do

  desc "Init photos_count of Wine"
  task :init_photos_count => :environment do
  	wines = Wine.where(["photos_count IS NULL"])
  	wines.each do |wine|
  		puts wine.id
  		wine.update_attribute(:photos_count, wine.photos.count)
  	end
  end


end
