# encoding: UTF-8
class FeedbacksController < ApplicationController

  def new
    build_feedback
  end

  def create
    build_feedback
    if @feedback.save
      redirect_to(success_feedbacks_path(:for => @for))
    else
      notice_stickie t("notice.feedback.create_failure")
      redirect_to(request.referer)
    end
  end

  def success

  end

  private
  def build_feedback
    if params.has_key? "feedback_error_feedback" || params[:for] == "error_feedback"
      @feedback = Feedback::ErrorFeedback.new(params[:feedback_error_feedback])
      @for = "error_feedback"
    elsif params.has_key? "feedback_complement_feedback" || params[:for] == "complement_feedback"
      @feedback = Feedback::ErrorFeedback.new(params[:feedback_complement_feedback])
      @for = "complement_feedback"
    else
      @feedback = Feedback::NormalFeedback.new(params[:feedback_normal_feedback])
      @for = "normal_feedback"
    end
  end
end
