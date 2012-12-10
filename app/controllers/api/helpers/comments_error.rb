module Api::Helpers
  class CommentsError < Error

    STATUS_MAPPING = { true => 'success', false => 'other_failed'}

    def initialize(status)
      super
      @status = status ? true : false
      @configs = @errors['comment']
    end

    def success
      begin
        @success ||= @configs[STATUS_MAPPING[@status]]['success']
      rescue
        0
      end
    end

    def code
      begin
        @code ||= @configs[STATUS_MAPPING[@status]]['code']
      rescue
        200
      end
    end

    def message
      begin
        @message ||= @configs[STATUS_MAPPING[@status]]['message']
      rescue
        ""
      end
    end

  end
end

