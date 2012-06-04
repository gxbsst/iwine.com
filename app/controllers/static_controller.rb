# encoding: UTF-8
class StaticController < ApplicationController

  def home
    @title =  t("nav.home")
  end
  def index
    @title =  t("nav.root")
  end

  def private
    @title =  t("nav.private")
  end

  def help
    @title = t("nav.help")
  end

  def site_map
    @title = t("nav.site_map")
  end

  def about_us
    @title =  t("nav.about_us")
  end

  def contact_us
    @title = t("nav.contact_us")
  end

  def feedback
    @title = t("nav.feedback")
    feedback_for = params[:for]
    case feedback_for
    when "error_feedbacks"
      render_error_feedbacks
    when "complement_feedbacks"
      render_complement_feedbacks
    else
      render_normal_feedbacks
    end
  end

  private

  def render_error_feedbacks
    @feedback = Feedback::ErrorFeedback.new
    render "error_feedbacks"
  end

  def render_normal_feedbacks
    @feedback = Feedback::NormalFeedback.new
    if user_signed_in?
      @feedback.email = current_user.email
      @feedback.name = current_user.username
    end
    render "feedback"
  end

  def render_complement_feedbacks
    @feedback = Feedback::ComplementFeedback.new
    render "complement_feedbacks"
  end

end
