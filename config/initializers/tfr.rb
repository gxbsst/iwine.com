ThemesForRails.config do |config|
  config.default_theme = "waterfall"
  # your static assets on Rails.root/themes/pink/assets/{stylesheets,javascripts,images}
  # config.use_sass = true
  # config.assets_dir = ":root/themes/:name/assets"
  config.themes_dir = ":root/app/assets/themes"
  config.assets_dir = ":root/app/assets/themes/:name"
  config.views_dir =  ":root/app/views/themes/:name"
  config.themes_routes_dir = "assets"
  # config.themes_dir = ':root/themes'
  # config.assets_dir = ":root/app/assets/themes/:name"
  # config.views_dir =  ":root/app/views/themes/:name"
  
  # config.themes_routes_dir = "assets" # by default, it uses themes
  # config.theme = :waterfall
  # config.views_dir =  ":root/app/views/themes/:name"
end