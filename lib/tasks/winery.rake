namespace :winery do
  
  desc "Init wines_count of Wine"
  task :init_wines_count => :environment do
  	wineries = Winery.where(:wines_count => 0)
  	wineries.each do |winery|
  		winery.update_attribute(:wines_count, winery.wines.count)
  	end
  end

end
