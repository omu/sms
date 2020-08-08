# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'

require 'open3'
require 'json'
require 'ostruct'

require 'sms'

require 'webmock'
require 'webmock/test_unit'

module Refinements
  refine String do
    def validate # rubocop:disable Metrics/MethodLength
      if (data = strip).start_with?('<?xml ')
        if `which xmllint`.empty?
          warn 'xmllint required (libxml2-utils package)'
          return true
        end

        _, _, status = Open3.capture3('xmllint --noout /dev/stdin', stdin_data: data)
        status.success?
      elsif data.start_with?('{') && data.end_with?('}')
        JSON.parse(data)
      else
        true
      end
    end
  end
end

class BasicSuite < Module
  using Refinements

  CONFIG = {
    from: 'FROM',
    no:   'NO',
    pass: 'PASS',
    user: 'USER'
  }.freeze

  MESSAGE = {
    body: 'BODY',
    date: 'DATE',
    from: 'FROM',
    to:   'TO'
  }.freeze

  attr_reader(*(ATTRIBUTES = %i[provider endpoint inset outset config].freeze))

  def initialize(**args)
    @provider = args.fetch(:provider)
    @endpoint = SMS::Provider.provider(provider).api.endpoint
    @inset    = OpenStruct.new(**args.fetch(:inset))
    @outset   = OpenStruct.new(**args.fetch(:outset))
    @config   = args.fetch(config, CONFIG).merge(provider: provider)

    validate!
  end

  def included(base)
    base.include InstanceMethods

    ATTRIBUTES.each do |attr|
      this = public_send(attr)
      base.define_method(attr) { this }
    end

    base.define_method(:message) do |*args|
      MESSAGE.merge(*args)
    end
  end

  private

  def validate!
    %i[inset outset].each do |attr|
      public_send(attr).to_h.each do |key, value|
        next unless value.is_a? String

        raise ArgumentError, "#{attr}.#{key} not valid" unless value.validate
      end
    end
  end

  module InstanceMethods
    def setup
      WebMock.enable!
    end

    def teardown
      SMS.unconfigure
      WebMock.reset_executed_requests!
      WebMock.disable!
    end

    def test_when_default
      WebMock.stub_request(:post, endpoint).to_return(body: outset.success, status: 200)
      SMS.configure(**config)
      SMS.(**message)
      WebMock.assert_requested :post, endpoint, body: inset.single
    end

    def test_when_not_default
      WebMock.stub_request(:post, endpoint).to_return(body: outset.success, status: 200)

      SMS.(**config, **message)
      WebMock.assert_requested :post, endpoint, body: inset.single
    end

    def test_multiple_receipents
      WebMock.stub_request(:post, endpoint).to_return(body: outset.success, status: 200)

      SMS.configure(**config)
      SMS.(**message(to: %w[TO1 TO2]))
      WebMock.assert_requested :post, endpoint, body: inset.multi
    end
  end
end
