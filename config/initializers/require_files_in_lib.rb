Dir[Rails.root + 'lib/core_ext/*.rb'].each do |file|
  require file
end

Dir[Rails.root + 'lib/validators/*.rb'].each do |file|
  require file
end

Dir[Rails.root + 'lib/sns/*.rb'].each do |file|
  require file
end

Dir[Rails.root + 'lib/exception/*.rb'].each do |file|
  require file
end

Dir[Rails.root + 'lib/notificationers/*.rb'].each do |file|
  require file
end

Dir[Rails.root + 'app/controllers/api/lib/*.rb'].each do |file|
  require file
end

Dir[Rails.root + 'app/controllers/api/helpers/*.rb'].each do |file|
  require file
end

Dir[Rails.root + 'app/controllers/service/*.rb'].each do |file|
  require file
end


require Rails.root + 'lib/patrick/hot_search.rb'

# 动态加入方法
OauthChina::Sina.class_eval do 
  include SNS::Sina
end

OauthChina::Qq.class_eval do 
  include SNS::Qq
end

OauthChina::Douban.class_eval do
  include SNS::Douban
end

