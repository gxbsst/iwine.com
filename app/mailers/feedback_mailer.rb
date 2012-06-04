# encoding: utf-8
class FeedbackMailer < ActionMailer::Base
	default from: APP_DATA["email"]["from"]["normal"], to: APP_DATA["email"]["to"]["feedback"]

	def feedback(feedback)
		@feedback = feedback
		mail(:subject => "反馈:#{feedback.subject}" )
	end

	def error_feedback(feedback)
		@feedback = feedback
		mail(:subject => "反馈:#{feedback.subject}" )
	end

	def complement_feedback(feedback)
		@feedback = feedback
		mail(:subject => "纠错:#{feedback.subject}" )
	end
end
