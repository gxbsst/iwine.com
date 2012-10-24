class Wines::VarietyPercentage < ActiveRecord::Base
  include Wines::WineSupport

  belongs_to :detail, :foreign_key =>  'wine_detail_id'
  belongs_to :variety
  delegate :name_zh, :to => :variety
  delegate :name_en, :to => :variety
  delegate :origin_name, :to => :variety

  def self.build_variety_percentage(variety_name, variety_percentage, wine_detail, logger = nil)
    variety_name.each_with_index do |value, index|
      next if value.blank?
      if wine_variety = Wines::Variety.where("lower(name_en) = ? or name_zh = ?", value.strip.downcase, value.strip).first
        percent = variety_percentage[index].blank? ? nil : variety_percentage[index].gsub(/\s+/, '')
        if percent && !percent.end_with?("%")
          logger.info("#{wine_detail.wine.name_en}, #{value}, #{variety_percentage[index]}, #{wine_detail.year}") if logger
          next
        end
        wine_variety.variety_percentages.
          where("wine_detail_id = ?", wine_detail.id).
          first_or_create(:wine_detail_id => wine_detail.id, :percentage => percent)
      end
    end
  end

  def self.build_variety_and_percentage(parent, percentage)
    Wines::VarietyPercentage.build_variety_percentage(percentage[:variety_name], percentage[:variety_percentage], parent)
    Wines::VarietyPercentage.delete(percentage[:destroy]) if percentage[:destroy]
  end

  def show_percentage
    percentage.to_s.include?("%") ? percentage : "#{percentage}%"
  end
end
