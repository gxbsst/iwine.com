# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * created_at [datetime, not null] - creation time
# * message [text, default=, not null] - TODO: document me
# * message_id [integer, default=0, not null, limit=8] - TODO: document me
# * updated_at [datetime, not null] - last update time
class SocialMessagePost < ActiveRecord::Base
end
