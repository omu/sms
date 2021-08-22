# frozen_string_literal: true

require 'erb'
require 'net/http'
require 'ostruct'
require 'uri'

class String
  # Stolen and adapted from ActiveSupport without acronym support
  def underscore
    return self unless /[A-Z-]|::/.match?(self)

    word = gsub('::', '/')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!('-', '_')
    word.downcase!
    word
  end
end

module OMU
  module SMS
    class Structable < Module
      Error = Class.new ArgumentError

      def self.call(*members, **defaults)
        new(*members, **defaults)
      end

      def self.build(required:, optional: [])
        this = self
        Class.new do
          include this.(*required, *optional)

          define_method :after_initialize do
            present!(only: required)
          end
        end
      end

      attr_reader :members, :defaults

      def initialize(*members, **defaults) # rubocop:disable Lint/MissingSuper
        @members  = [*members, *defaults.keys].uniq
        @defaults = defaults
      end

      def included(base)
        super

        members, defaults = self.members, self.defaults

        base.attr_accessor(*members)

        base.define_singleton_method(:members)  { members  }
        base.define_singleton_method(:defaults) { defaults }

        base.include InstanceMethods
        base.extend  ClassMethods
      end

      module InstanceMethods
        def initialize(**args) # rubocop:disable Lint/MissingSuper
          self.class.defaults.each do |attr, value|
            public_send "#{attr}=", value
          end

          before_initialize if respond_to? :before_initialize
          update(**args)
          after_initialize if respond_to? :after_initialize
        end

        def update(**args)
          args.each do |attr, value|
            next unless self.class.members.include? attr

            public_send("#{attr}=", value)
          end
          self
        end

        def present!(only: nil, except: nil) # rubocop:disable all
          required = if !only && !except
                       self.class.members
                     elsif only && !except
                       only
                     elsif !only && except
                       self.class.members - except
                     else
                       only - except
                     end

          return if (missings = required.reject { |member| public_send(member) }).empty?

          raise Error, "Missing attribute(s): #{missings.join(', ')}"
        end

        def to_h
          {}.tap do |h|
            self.class.members.each { |attr| h[attr] = public_send(attr) }
          end
        end
      end

      module ClassMethods
        def consume!(hash)
          new(**hash.slice(*members)).tap do
            members.each { |member| hash.delete(member) }
          end
        end
      end
    end

    module Renderable
      def render(*hashables)
        hashables.each do |hashable|
          next if hashable.respond_to?(:to_h)

          raise NotImplementedError, "Object can not be coerced into a Hash: #{hashable}"
        end

        Rendered.new(
          (respond_to?(:to_h, true) ? to_h : {}).merge(
            *hashables.map(&:to_h)
          )
        )._render((respond_to?(:template, true) ? template : self.class.template).to_s)
      end

      class Rendered < OpenStruct
        def _render(template)
          ERB.new(template, trim_mode: '-', eoutvar: '_erbout').result(binding)
        rescue StandardError => e
          raise Error, "Render error: #{e.message}"
        end
      end

      private_constant :Rendered
    end

    module HTTP
      Error = Class.new(SMS::Error) # Better to classify network errors separately

      module_function

      DEFAULT_OPTION = { use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_PEER }.freeze
      DEFAULT_HEADER = {}.freeze

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def post(data:, endpoint:, options: {}, header: {})
        uri = URI.parse(endpoint)

        http = Net::HTTP.new(uri.host, uri.port).tap do |this|
          DEFAULT_OPTION.merge(options).each { |key, value| this.public_send("#{key}=", value) }
        end

        request      = Net::HTTP::Post.new(uri.request_uri, DEFAULT_HEADER.merge(header))
        request.body = data.to_s

        begin
          http.request(request)
        rescue StandardError => e # Why? See https://stackoverflow.com/a/11802674
          raise Error, "Error on posting: #{e.message}"
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    end
  end
end
