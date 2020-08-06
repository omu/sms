# frozen_string_literal: true

module SMS
  class Result
    attr_reader :response, :detail
    attr_accessor :error

    def initialize(response)
      @response = response
      @detail   = OpenStruct.new
      @error    = nil
    end

    def ok?
      error.nil?
    end

    def notok?
      !ok?
    end

    def inspect
      detail.to_h
    end
  end
end
