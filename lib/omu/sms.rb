# frozen_string_literal: true

require_relative 'sms/error'
require_relative 'sms/support'
require_relative 'sms/message'
require_relative 'sms/result'
require_relative 'sms/dsl'
require_relative 'sms/provider'

module OMU
  module SMS
    class << self
      attr_accessor :default_provider
    end

    module_function

    def configure(**args)
      config = OpenStruct.new(**args)
      yield(config) if block_given?

      self.default_provider = Provider.create(**config.to_h)
    end

    def unconfigure
      self.default_provider = nil
    end

    def call(**args)
      return default_provider.call(Message.new(**args)) if default_provider

      Provider.call(**args)
    end
  end
end
