#encoding: utf-8

namespace :exchange_rate do 
  desc "初始化 货币中类表"

  task :init_exchange_rate => :environment do 
    #['英文名称', '中文名称', '和人民币对应的汇率']
    rates = [['CNY', '人民币',1]]

    rates.each do |r|
      ExchangeRate.where(:name_en => r[0]).first_or_create(:name_en => r[0], :name_zh => r[1], :rate => r[2])
    end
  end
end