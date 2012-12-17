# ‘~> 2.2’ is equivalent to:[‘>= 2.2’, ‘< 3.0’] and '~> 2.2.0' is equivalent to:[‘>= 2.2.0’, ‘< 2.3.0’]
source 'http://rubygems.org/'

gem 'rails', '3.2.5'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'mysql2', '0.3.11'
gem 'jquery-rails', :git => 'git://github.com/indirect/jquery-rails', :branch => 'c1eb6aeeb213' #, :tag => "v2.0.1"
gem 'devise', "~> 2.0.4"
gem 'cancan', '1.6.8'
gem 'passenger', '3.0.17'
gem 'kaminari', '0.14.1'
#gem 'uploadify'
# gem 'flash_cookie_session'
gem 'best_in_place', '1.1.2'
# gem 'contacts_cn'  # 连接email
# gem 'hpricot'

#gem "rmagick"
gem "mini_magick", '3.4'
gem "carrierwave", '0.5.8'
gem "fileutils", '0.7'

gem 'omniauth', '1.1.1'
gem 'oauth', '0.4.7'
gem 'oauth2', '0.8.0'
gem 'oauth_china', '0.5.0'

# Memcache
gem 'memcache-client', '1.8.5'

gem 'rails-i18n', '0.7.0'

gem 'fancybox-rails', :git => 'git://github.com/sverigemeny/fancybox-rails', :ref => "17db886581f3"
gem 'jcrop-rails', '1.0.2'
gem 'backbone-on-rails', '0.9.2.3'
gem "jquery-tools", "~> 0.0.3"

gem 'client_side_validations', '3.2.1'

gem 'activeadmin', '0.5.0'

gem 'hanzi_to_pinyin', :git => 'git://github.com/wxianfeng/hanzi_to_pinyin.git', :branch => '1f1891ff6f37'

# gem "breadcrumbs_on_rails"

## Exception Handler
gem 'exception_notification', '3.0.0', :require => 'exception_notifier'

## Success/Notice/Error Style
gem "stickies", :git => "git://github.com/techbang/stickies.git", :branch => '5b18fae852f7'

gem 'store_configurable', '~> 3.2.0'

## Message
gem 'mailboxer', '0.6.5' #如果更新到 0.8.0需要更改数据库字段

## Comment
gem 'acts_as_commentable_with_threading', :path => "lib/gems"
# Vote
gem 'acts_as_votable', :path => "lib/gems"

## Timeline
gem "timeline_fu", :path => "lib/gems"

# Friendly URL

gem "friendly_id", '4.0.8'

group :development do
  gem "better_errors", '0.2.0'
  gem "binding_of_caller", '0.6.8'
end

group :development, :test do
  gem 'i18n', '0.6.1'
  gem 'pry', '0.9.10'  # "binding.pry" in action
  gem 'wirble', '0.1.3'
  gem 'rspec-rails', '2.11.4'
  # 优化
  #gem "query_revie wer", :git => "git://github.com/nesquena/query_reviewer.git"
  gem "bullet", '4.2.0'
  #gem 'growl'
  #gem 'ruby-growl'
  gem "uniform_notifier", '1.1.0'
  # gem 'slowgrowl'
  gem "thin", '1.5.0'
  gem 'sextant', '0.1.3' #通过 http://localhost:3000/rails/routes 查看routes
  gem 'annotator', '0.0.8.1'
  gem 'rack-mini-profiler', '0.1.22'
end
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails', '1.0.3'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
gem 'unicorn', '4.4.0'

# Deploy with Capistrano
gem 'capistrano', '2.13.4'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  gem "factory_girl_rails", '4.1.0'
  gem "capybara", '1.1.2'
  gem "guard-rspec", '2.1.0'
  gem "database_cleaner", '0.9.1'
  # Pretty printed test output
  gem 'turn', :require => false
  gem "spork", '0.9.2'
  gem 'growl', '1.0.3'
  gem "guard-spork", '1.2.1'
  gem "autotest-rails", '4.1.2'
  gem "ZenTest", '4.8.2'
  gem 'simplecov', '0.7.1', :require => false
  gem 'metrical', '0.1.0', :require => false
end

gem 'user_resource_init', :path => 'lib/patrick/user_resource_init'

# 计数
gem 'counter', :path => 'lib/patrick/counter'


# step form
gem 'wicked', '0.2.0'

gem 'omniauth-qq-connect', '0.2.0'
gem 'omniauth-weibo-oauth2', '0.2.0'
gem 'omniauth-renren', :path => 'lib/gems/ballantyne-omniauth-renren'
# API VERSION
gem 'versionist', '0.3.1'
# XML Parser
gem 'nokogiri', '1.5.5'

gem 'delayed_job_active_record', '0.3.3'

# Tagging
gem 'acts-as-taggable-on', '~> 2.3.1'

# address  latitude & longitude
gem "geocoder", '1.1.4'
gem 'google_places', '0.1.1'

# crontab
#gem 'rcov', '0.9.11'
gem 'whenever', '0.6.8', :require => false
#, :git => 'git://github.com/javan/whenever'

# monitor
gem 'newrelic_rpm', '3.5.0.1'
gem 'garelic', '0.1.1'

# delay job
gem 'daemons', '1.1.9'

# 虚拟属性 象  active record
gem 'virtus', '0.5.2'
