class Wines::VarietyPercentage < ActiveRecord::Base
  include Wines::WineSupport

  belongs_to :detail, :foreign_key =>  'wine_detail_id'
  belongs_to :variety
  delegate :name_zh, :to => :variety
  delegate :name_en, :to => :variety
  delegate :origin_name, :to => :variety

  def self.build_variety_percentage(variety_name, variety_percentage, wine_detail_id)
    variety_name.each_with_index do |value, index|
      next if value.blank?
      if wine_variety = Wines::Variety.where("name_en = ? and wine_detail_id = ? ", value.strip, wine_detail_id).first
        wine_variety.variety_percentages.first_or_create(:wine_detail_id => wine_detail_id, :percentage => variety_percentage[index])
      end
    end
  end

  def self.build_variety_and_percentage(parent, percentage)
    Wines::VarietyPercentage.build_variety_percentage(percentage[:variety_name], percentage[:variety_percentage], parent.id)
    Wines::VarietyPercentage.delete(percentage[:destroy]) if percentage[:destroy]
  end

  def show_percentage
    percentage.to_s.include?("%") ? percentage : "#{percentage}%"
  end
end
