#encoing: utf-8
module Service
  module MailerService

    class Mailer  # 赞

      HOST = Rails.configuration.action_mailer.default_url_options[:host]

      #params
      # mailer UserMailer
      # action :action_name
      def self.deliver(mailer, action, params)
        new(mailer, action, params).process
      end

      def initialize(mailer, action, params)
        @mailer = mailer
        @action = action
        @params = params
      end

      def process
        @mailer.send(@action, @params).deliver
      end

    end

  end
end