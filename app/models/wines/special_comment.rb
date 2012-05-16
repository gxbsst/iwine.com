#encoding UTF-8
class Wines::SpecialComment  < ActiveRecord::Base
  include Wines::WineSupport
  belongs_to :special_commentable, :polymorphic => true

  def self.build_special_comment(parent, attributes)
    attributes[:name].each_with_index do |name, index|
      next if name.blank?
      parent.special_comments.where("name = ?", name).first_or_create(
        :name => name,
        :score => attributes[:score][index],
        :drinkable_begin => DateTime.parse("#{attributes[:drinkable_begin][index]}0101"),
        :drinkable_end => DateTime.parse("#{attributes[:drinkable_end][index]}0101")
      )
    end
    Wines::SpecialComment.delete(attributes[:destroy]) if attributes[:destroy]

  end

  def self.change_special_comment_to_wine(detail, register)
    register.special_comments.each do |s|
      detail.special_comments.create(:name => s.name, :score => s.score, :drinkable_begin => s.drinkable_begin, :drinkable_end => s.drinkable_end)
    end
  end
end