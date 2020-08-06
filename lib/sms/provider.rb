# frozen_string_literal: true

module SMS
  module Provider
    module_function

    def available
      @available ||= {}
    end

    def provider(name)
      available[name.to_sym].tap do |this|
        raise Error, "Unknown provider: #{name}" unless this
      end
    end

    def create(**args)
      raise Error, 'Provider required' unless (name = args.delete(:provider))

      Provider.provider(name).new(**args)
    end

    def call(**args)
      create(**args).call(Message.new(**args))
    end

    class Base
      extend  DSL
      include Renderable

      def self.inherited(klass)
        SMS::Provider.available[klass.name.underscore.split('/').last.to_sym] = klass
      end

      attr_reader :config, :purpose

      def initialize(**args)
        @purpose = args.delete(:purpose) || :default
        @config  = template.config_class.new(**args)
        after_initialize
      rescue ArgumentError => e
        raise Error, "#{self.class}: #{e.message}"
      end

      def call(message)
        post render(config, message)
      end

      protected

      def after_initialize; end

      def template
        self.class.templates[purpose]
      end

      def post(data) # rubocop:disable Metrics/AbcSize
        api, callbacks = self.class.api, self.class.callbacks

        result = Result.new SMS::HTTP.post(data: data, endpoint: api.endpoint, options: api.options, header: api.header)
        callbacks.success.(result)
        raise ProviderError, result.error if result.notok?

        result
      rescue HTTP::Error => e
        result.error = e.message
        callbacks.failure&.(result)
        raise
      end

      def on_http_success(*)
        raise NotImplementedError
      end

      def on_http_failure(*)
        # optional
      end

      def to_h
        config.to_h
      end
    end
  end

  require_relative 'provider/ileti_merkezi'
  require_relative 'provider/mutlu_cell'
  require_relative 'provider/vatan_sms'
  require_relative 'provider/verimor'
end
