#encoding: utf-8
namespace :wines_count_of_winery do
  desc "重新统计酒庄下面酒的数目。"
  task :begin_count => :environment do
    Winery.all.each do |winery|
      winery.update_attribute(:wines_count, winery.wines.count)
      puts "winery: #{winery.id} #{winery.wines_count}"
    end
  end
end