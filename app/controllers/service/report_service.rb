#encoing: utf-8
module Service
  module ReportService

    class NoteReport  # 赞
      def self.process(params)
        new(params).create
      end

      def initialize(params)
       @params = params
      end

      def create
        f = Feedback::NoteReport.create(@params)
        Service::MailerService::Mailer.deliver(FeedbackMailer, :note_report, f) unless f.errors.any?
        f
      end
    end

  end
end