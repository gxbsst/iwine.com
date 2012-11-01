#encoding: utf-8
namespace :fix_wine_data do
  desc "将酒和酒庄的其它中文名填充到cn_names表中"  
  task :fix_data => :environment do
    puts "=============== fix_data begin"
    begin
      Wines::Register.all.each do |register|
        winery = Winery.where('name_en = ?', register.winery_name_en).first
        if winery
          wine = Wine.where('name_en = ? and winery_id is null', register.name_en).first
          if wine
            wine.update_attribute(:winery_id, winery.id)
            puts "wine_id: #{wine.id}, winery_id: #{wine.winery_id}"
          else
            puts "register: #{register.id}"
          end
        end
      end
    rescue Exception => e
      puts e
    end
  end
end