# frozen_string_literal: true

require_relative 'sms/support'
require_relative 'sms/error'
require_relative 'sms/message'
require_relative 'sms/dsl'
require_relative 'sms/provider'

require 'active_support/all'

module SMS
  mattr_accessor :default_provider

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
