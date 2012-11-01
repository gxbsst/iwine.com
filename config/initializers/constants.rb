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
  'weibo',
  'qq',
  'douban'
]

EMAIL_SERVERS = [
  'gmail' ,
  'qq'
]

if Rails.env == 'production'
  OAUTH_DATA = YAML.load_file(Rails.root.join('config', 'oauth', 'production_all.yml'))
  QQ_PIC_URL = "http://www.iwine.com"
else
  QQ_PIC_URL = "http://dev.iwine.com"
  OAUTH_DATA = YAML.load_file(Rails.root.join('config', 'oauth', 'development_all.yml'))
end
APP_DATA = YAML.load_file(Rails.root.join('config', 'data.yml')) 

EMAIL_SITE = YAML.load_file(Rails.root.join('config', 'email_site.yml'))

## USER CONFIGs
USER_CONFIG_NORMAL = "1"
# EMAIL
USER_CONFIG_RECIEVE_MESSAGE_EMAIL = "1"
USER_CONFIG_RECIEVE_REPLY_EMAIL = "2"
USER_CONFIG_FOLLOWED_EMAIL = "3"
USER_CONFIG_RECIEVE_PORODUCT_INFO_EMAIL = "4"
USER_CONFIG_RECIEVE_ACCOUNT_INFO_EMAIL = "5"

# MESSAGE
USER_CONFIG_MESSAGE_FROM_ALL = "1"
USER_CONFIG_MESSAGE_FROM_MY_FOLLOWING = "3"


