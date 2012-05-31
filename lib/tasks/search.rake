namespace :search do
  desc "Rebuild Search Index"
  task :build => :environment do
  	puts "...................................................................................."
  	`curl http://www.sidways.com:8080/patrick/build >> /dev/null`
  	puts "...................................................................................."
  	puts "Cool...It's Done;-)"
  end

end
