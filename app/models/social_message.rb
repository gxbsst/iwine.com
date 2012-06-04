# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * created_at [datetime, not null] - creation time
# * delete_by_recipient [boolean, not null, limit=1] - TODO: document me
# * delete_by_sender [boolean, not null, limit=1] - TODO: document me
# * no_reply [boolean, not null, limit=1] - TODO: document me
# * read [boolean, not null, limit=1] - TODO: document me
# * read_time [integer, default=0, not null, limit=4] - TODO: document me
# * recipient [string, default=, not null] - TODO: document me
# * recipient_id [integer, default=0, not null, limit=4] - TODO: document me
# * send_time [integer, default=0, not null, limit=4] - TODO: document me
# * sender [string, default=, not null] - TODO: document me
# * sender_id [integer, default=0, not null, limit=4] - TODO: document me
# * subject [string, default=, not null] - TODO: document me
# * updated_at [datetime, not null] - last update time
class SocialMessage < ActiveRecord::Base
end
