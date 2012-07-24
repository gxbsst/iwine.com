# encoding: utf-8
# require 'icov'
class Users::WineCellarItem < ActiveRecord::Base
    set_table_name "user_wine_cellar_items"
    include Users::UserSupport
    belongs_to :wine_cellar, :class_name => 'Users::WineCellar', :foreign_key => 'user_wine_cellar_id'
    belongs_to :user
    belongs_to :wine_detail, :class_name => 'Wines::Detail', :foreign_key => 'wine_detail_id'
    
    attr_accessor :year, :capacity
    # attr_accessible :year, :capacity, :user_wine_cellar_id, :wine_detail_id, :price, :inventory
    attr_protected :user_id
    
    validates_inclusion_of :number, :in => 1..1000, :message => '请输入正确的数字'
    # validates_presence_of :buy_from

    validates :price, :numericality => {:allow_blank => true}

    
    # paginate config
    paginates_per 6
    
    fires :add_to_cellar, :on            => :create,
                        :actor           => :user,
                        :secondary_actor => :wine_detail,
                        :if => lambda {|item| item.user.profile.config.share.wine_cellar.to_i == 1}



 def self.to_csv(options = {})
  # CSV.generate(options) do |csv|
  #   head = 'EF BB BF'.split(' ').map{|a|a.hex.chr}
  #   csv << head
  #   csv << column_names
  #   all.each do |product|
  #     csv << product.attributes.values_at(*column_names)
  #   end
  # end

  # write_content = Iconv.conv("utf-16le", "utf-8", "\xEF\xBB\xBF")
  # write_content += Iconv.conv("utf-16le", "utf-8", csv_content)
  # File.open("listing.csv", 'wb') {|f| f.write(write_content) }

    csv_final = CSV.generate(options) do |csv|

       csv << column_names
       all.each do |cellar_items|
       csv << cellar_items.attributes.values_at(*column_names)
    #         # @cellar_items = @cellar.items
    #         # cellar_items.each do |item|
    #         # wine_detail = item.wine_detail 
    #         # csv << 
    #         #    wine_detail.show_year 
    #         #    wine_detail.wine.name_zh
    #         #    wine_detail.show_capacity
    #         #    item.number
    #         #    item.buy_date.strftime("%Y年%m月%d日") unless item.buy_date.blank?
    #         #    number_to_currency(item.price,  :unit => "CNY")
    #         #    item.location
    #         end
    #     # end
       end
    end
  end

end
