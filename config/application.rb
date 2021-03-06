# encoding: utf-8
require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Patrick
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    #config.autoload_paths += Dir["#{config.root}/app/modes/concerns/**/"]
    config.autoload_paths += %W(#{config.root}/app/models/*) + %W(#{config.root}/app/models/concerns)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = "zh-CN"

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.active_record.observers = :timeline_event_observer, :photo_observer

    #protect us from having models without attr_accessible set.
#    config.active_record.whitelist_attributes = true
    ## Fixed
    # DEPRECATION WARNING: ActiveSupport::Memoizable is deprecated...
    ActiveSupport::Deprecation.silenced = true

    # Usage: ceated_at.to_s(:cn)
    Time::DATE_FORMATS[:normal] = "%Y-%m-%d"
    Time::DATE_FORMATS[:yt] = "%m.%d %I:%M"
    Time::DATE_FORMATS[:cn] = "%Y年%m月%d日  %I:%M"
    Time::DATE_FORMATS[:cn_short] = "%m月%d日"
    Time::DATE_FORMATS[:cn_yt] = "%m月%d日  %I:%M"
    Time::DATE_FORMATS[:year] = "%Y"
    Time::DATE_FORMATS[:cn_normal] = "%Y-%m-%d %I:%M" 
    Time::DATE_FORMATS[:app_time] = "%Y-%m-%d %H:%M:%S"
    if Rails.env.development?
      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    end
  end
end
