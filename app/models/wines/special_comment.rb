#encoding UTF-8
class Wines::SpecialComment  < ActiveRecord::Base
  include Wines::WineSupport
  belongs_to :special_commentable, :polymorphic => true
end