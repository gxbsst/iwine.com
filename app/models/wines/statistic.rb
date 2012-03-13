class Wines::Statistic < ActiveRecord::Base
include Wines::WineSupport
belongs_to :detail, :foreign_key => 'wine_detail_id'

  def avarage_score
    if score_user_count == 0
      return 0.to_f
    end
    ( score_sum.to_f / score_user_count * 10 ).round / 10.to_f
  end
end