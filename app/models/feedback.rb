# encoding: utf-8
# Attributes:
# * id [integer, primary, not null, limit=4] - primary key
# * created_at [datetime, not null] - creation time
# * description [text] - TODO: document me
# * email [string]
# * name [string]
# * subject [string] - TODO: document me
# * type [string] - TODO: document me
# * updated_at [datetime, not null] - last update time
class Feedback < ActiveRecord::Base

  has_many :normal_feedbacks
  has_many :error_feedbacks
  has_many :complement_feedbacks

  validates_presence_of :subject, :on => :create, :message => "不能为空."
  validates :email,
  :presence   => true,
  :format     => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }

  after_create :send_email
  def send_email
    if type == "Feedback::ErrorFeedback"
      FeedbackMailer.error_feedback(self).deliver
    elsif type == "Feedback::ComplementFeedback"
      FeedbackMailer.complement_feedback(self).deliver
    elsif type == "Feedback::NoteReport"
      true # do nothing
    else
      FeedbackMailer.feedback(self).deliver
    end
  end

  # 反馈
  class NormalFeedback < Feedback; end

  # 纠错
  class ErrorFeedback < Feedback; end

  # 补充
  class ComplementFeedback < Feedback; end

  #品酒辞举报
  class NoteReport < Feedback; end

end
