# encoding: utf-8
module Wines
   module WineSupport

     def self.included(base)
       base.table_name = 'wine_' + base.table_name unless base.table_name =~/^wine\_/
       base.extend ClassMethods
     end
    
     def all_vintage
       Wines::Detail.where(["wine_id = ?", wine_id]).select("year, id")
     end

     # Class Methods
     module ClassMethods
       # Wine 项目要用到的公共 class methods       
     end
     
     # 官方网站
     def html_official_site
       "http://" + official_site
     end

     # 评分
     def score
      # 总评价数量
      rate_comments_count 
      # 5星比例
      five_stars_percentage  = star_percentage(5, rate_comments_count)
      four_stars_percentage  = star_percentage(4, rate_comments_count)
      three_stars_percentage = star_percentage(3, rate_comments_count)
      two_stars_percentage   = star_percentage(2, rate_comments_count)
      one_stars_percentage   = star_percentage(1, rate_comments_count)

      # 评分 = (10 x 5星比例) + (8 x 4星比例) + ... + (2 x 1星比例)
      score = (10 * five_stars_percentage ) + 
              (8 * four_stars_percentage ) + 
              (6 * three_stars_percentage ) +  
              (4 * two_stars_percentage ) +  
              (2 * one_stars_percentage ) 

      @score = score.round(1)
     end

     # 星级
     def stars
       
       (score / 2).round(0)
     end

     # 评分总数
     def rate_comments_count
       comments.where("point > 0").count
     end

     def get_label
       label = case self.class.name
                 when "Wines::Detail"
                   self.label ? self.label : self.wine.label
                 when "Wine"
                   self.label
               end
       return label
     end

     private

     # 评星与总评分
     def star_percentage(star, rate_comments_count)
      if comments.with_point_is(star).count > 0
        (comments.with_point_is(star).count.to_f / rate_comments_count).round(1)
      else
        0
      end
     end

   end
end