class Wines::Comment < ActiveRecord::Base
  include Wines::WineSupport

#  belongs_to :detail, :foreign_key => 'wine_detail_id'
#  belongs_to :user, :include => [:good_hi]

  has_one :user_good_hit, :class_name => 'Users::GoodHitComment', :conditions => ["user_good_hit_comments.user_id = ?", User::current_user ? User::current_user.id : -1 ]

  belongs_to :user
  has_one :avatar, :class_name => 'Photo', :primary_key => :user_id,  :foreign_key => 'business_id', :conditions => { :is_cover => true }

  #has_one :good_hit_comment, :class_name => 'Users::GoodHitComment'

  belongs_to :detail, :class_name => "Wines::Detail", :foreign_key => 'wine_detail_id'

  @prepared = false

  # paginate config
  paginates_per 10

  before_save :check_point

  after_save :update_statistic

  after_destroy :update_statistic

  def self.get_user_session_id
    session[:user_id]
  end

  def check_point
    if drink_status == 'want' || point < 0 || point > 10
      write_attribute :point, 0
    end
  end

  def update_statistic
    unless @prepared
      return
    end

    statistic = detail.statistic || detail.build_statistic

    if @is_new
      statistic.comment_count += 1

      if drink_status == 'want'
        statistic.to_drink_user_count += 1
      elsif drink_status == 'drank'
        statistic.drank_user_count += 1

        if point.to_i > 0
          statistic.score_sum += point
          statistic.score_user_count += 1
        end
      end
    elsif destroyed?
      if @attr_copy['drink_status'] == 'drank'
        statistic.drank_user_count -= 1
      elsif @attr_copy['drink_status'] == 'want'
        statistic.to_drink_user_count -= 1
      end
      if @attr_copy['point'] > 0
        statistic.score_sum -= @attr_copy['point']
        statistic.score_user_count -= 1
      end
      statistic.comment_count -= 1
    else
      if drink_status == 'want'
        if @attr_copy['drink_status'] == 'drank'
          statistic.to_drink_user_count += 1
          statistic.drank_user_count -= 1
        end
      elsif drink_status == 'drank'
        if @attr_copy['drink_status'] == 'want'
          statistic.to_drink_user_count -= 1
          statistic.drank_user_count += 1
        end
      end

      if point.to_i > 0
        if @attr_copy['point'] == 0
          statistic.score_user_count += 1
        end
      else
        if @attr_copy['point'] > 0
          statistic.score_user_count -= 1
        end
      end
      statistic.score_sum += point - @attr_copy['point']
    end

    statistic.save
  end

  def prepare_update
    unless new_record?
      @attr_copy = attributes
    end

    @is_new = new_record?
    @prepared = true
  end
end
