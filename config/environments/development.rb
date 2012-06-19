Patrick::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # mailer
  config.action_mailer.delivery_method = :smtp

  config.action_controller.perform_caching = true

  # Bullet
  Bullet.enable = true
  # Bullet.alert = true
  Bullet.bullet_logger = true
  # Bullet.console = true
  # Bullet.growl = true
  # Bullet.xmpp = { :account => 'gxbsst@jabber.org',
  #   :password => '51448888',
  #   :receiver => 'gxbsst@jabber.org',
  #   :show_online_status => true }
  Bullet.rails_logger = true
  # Bullet.disable_browser_cache = true

  # javascript alert
  # UniformNotifier.alert = true

  # javascript console (Safari/Webkit browsers or Firefox w/Firebug installed)
  # UniformNotifier.console = true

  # rails logger
  UniformNotifier.rails_logger = true

  # customized logger
  # logger = File.open('notify.log', 'a+')
  # logger.sync = true
  # UniformNotifier.customized_logger = logger

  # growl without password
  # UniformNotifier.growl = true

  # config.slowgrowl.warn = 1000    # growl any action which takes > 1000ms (1s)
  # config.slowgrowl.sticky = true  # make really slow (2x warn) alerts sticky
  config.action_controller.perform_caching = true
  config.cache_store = :mem_cache_store, "192.168.11.31"
end
