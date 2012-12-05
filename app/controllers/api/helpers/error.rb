module Api::Helpers

  class Error
    def initialize(status)
      @status = status
      @errors = APP_DATA['api']['return_json']
    end

    def code; end

    def message; end

    def success; end
  end

end