
## audit_log
OWNER_TYPE_USER = 1
OWNER_TYPE_WINE = 2
OWNER_TYPE_WINERY = 3
OWNER_TYPE_WINE_REGISTER = 4
OWNER_TYPE_PHOTO = 5
## info_items
INFO_TYPE_WINEMAKER = 1
INFO_TYPE_HISTORY = 2

## audit_log
OWNER_TYPES = {
  OWNER_TYPE_USER => 'user',
  OWNER_TYPE_WINE => 'wine',
  OWNER_TYPE_WINERY => 'winery',
  OWNER_TYPE_WINE_REGISTER => 'wine_register'
}

SNS_SERVERS = [
  'sina',
  'qq',
  'douban'
]

EMAIL_SERVERS = [
  'gmail' ,
  'qq'
]


APP_DATA = YAML.load_file(Rails.root.join('config', 'data.yml'))

EMAIL_SITE = YAML.load_file(Rails.root.join('config', 'email_site.yml'))
