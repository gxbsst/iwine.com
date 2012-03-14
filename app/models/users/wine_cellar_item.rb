# encoding: utf-8
class Users::WineCellarItem < ActiveRecord::Base
    include Users::UserSupport
    belongs_to :wine_cellar
    belongs_to :wine_detail, :class_name => 'Wines::Detail', :foreign_key => 'wine_detail_id'
    
    attr_accessor :year, :capacity
    # attr_accessible :year, :capacity, :user_wine_cellar_id, :wine_detail_id, :price, :inventory
    attr_protected :user_id
    
    validates_inclusion_of :number, :in => 1..1000, :message => '请输入正确的数字'
    validates_presence_of :buy_from
    validates_presence_of :year

    
    # paginate config
    paginates_per 6
  
end
 