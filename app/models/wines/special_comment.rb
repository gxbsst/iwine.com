#encoding UTF-8
class Wines::SpecialComment  < ActiveRecord::Base
  # include Wines::WineSupport
  set_table_name "wine_special_comments"
  belongs_to :special_commentable, :polymorphic => true

  def self.build_special_comment(parent, attributes)
    attributes[:name].each_with_index do |name, index|
      next if name.blank?
      parent.special_comments.where("name = ? and score = ?", name, attributes[:score][index]).first_or_create(
        :name => name,
        :score => attributes[:score][index],
        :drinkable_begin => DateTime.parse("#{attributes[:drinkable_begin][index]}0101"),
        :drinkable_end => DateTime.parse("#{attributes[:drinkable_end][index]}0101")
      )
    end
    Wines::SpecialComment.delete(attributes[:destroy]) if attributes[:destroy] #删除已经保存过的special_comment

  end

  def self.change_special_comment_to_wine(detail, register)
    register.special_comments.each do |s|
      detail.special_comments.create(:name => s.name, :score => s.score, :drinkable_begin => s.drinkable_begin, :drinkable_end => s.drinkable_end)
    end
  end

  #添加酒款"完善信息"时展示时间

  def drinkable
    "#{drinkable_begin.to_s(:year)}-#{drinkable_end.to_s(:year)}"
  end
end