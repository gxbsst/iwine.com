# -*- coding: utf-8 -*-
module TimelineFu
  module Fires
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def fires(event_type, opts)
        raise ArgumentError, "Argument :on is mandatory" unless opts.has_key?(:on)

        # Array provided, set multiple callbacks
        if opts[:on].kind_of?(Array)
          opts[:on].each { |on| fires(event_type, opts.merge({:on => on})) }
          return
        end

        opts[:subject] = :self unless opts.has_key?(:subject)

        method_name = :"fire_#{event_type}_after_#{opts[:on]}"
        define_method(method_name) do
          create_options = [:actor, :subject, :secondary_subject, :secondary_actor].inject({}) do |memo, sym|
            case opts[sym]
            when :self
              memo[sym] = self
            else
              memo[sym] = send(opts[sym]) if opts[sym]
            end
            memo
          end
          create_options[:event_type] = event_type.to_s

          # 这里主要是为了解决用户评论时，区分是评论还是关注, 只对Comment有效
          if self.class.base_class.name == "Comment"
            create_options[:event_type] = "new_follow" if self.do == "follow"
          end

          TimelineEvent.create!(create_options)
        end

        send(:"after_#{opts[:on]}", method_name, :if => opts[:if])
      end

      # def fires_for_wine(event_type, opts)
      #   raise ArgumentError, "Argument :on is mandatory" unless opts.has_key?(:on)
      #
      #   # Array provided, set multiple callbacks
      #   if opts[:on].kind_of?(Array)
      #     opts[:on].each { |on| fires(event_type, opts.merge({:on => on})) }
      #     return
      #   end
      #
      #   opts[:subject] = :self unless opts.has_key?(:subject)
      #
      #   method_name = :"fire_for_wine_#{event_type}_after_#{opts[:on]}"
      #   define_method(method_name) do
      #     create_options = [:actor, :subject, :secondary_subject].inject({}) do |memo, sym|
      #       case opts[sym]
      #       when :self
      #         memo[sym] = self
      #       else
      #         memo[sym] = send(opts[sym]) if opts[sym]
      #       end
      #       memo
      #     end
      #     create_options[:event_type] = event_type.to_s
      #
      #     UserTimelineEvent.create!(create_options)
      #   end
      #
      #   send(:"after_#{opts[:on]}", method_name, :if => opts[:if])
      # end

    end
  end
end
