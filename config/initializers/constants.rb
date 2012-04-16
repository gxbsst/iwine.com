
## photos
OWNER_TYPE_USER = 1
OWNER_TYPE_WINE = 2
OWNER_TYPE_WINERY = 3
OWNER_TYPE_WINE_REGISTER = 4

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
