module Api::Helpers
  class Result
    include Virtus

    attribute :success
    attribute :resultCode
    attribute :message
    attribute :data

    def initialize(data, error)
      @error = error
      @data = data
    end

    def success
      @error.success
    end

    def resultCode
      @error.code
    end

    def message
      @error.message
    end

    def data
      @data
    end

  end
end