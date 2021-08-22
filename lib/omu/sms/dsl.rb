# frozen_string_literal: true

module OMU
  module SMS
    module DSL
      API      = Struct.new :endpoint, :header, :options, keyword_init: true

      Template = Struct.new :required, :content, keyword_init: true do
        def config_class
          Structable.build(required: required)
        end

        def to_s
          content
        end
      end

      Callback = Struct.new(:success, :failure, :init, keyword_init: true) do
        def self.create
          empty = proc {}

          new success: empty, failure: empty, init: empty
        end
      end

      def posting(endpoint:, header: {}, options: {})
        @api = API.new endpoint: endpoint, header: header, options: options
      end

      ALWAYS_REQUIRED = %i[
        from
        pass
        user
      ].freeze

      def rendering(content:, required: [])
        @template = Template.new(required: [*ALWAYS_REQUIRED, *required].uniq, content: content)
      end

      def calling(on: :success, &block)
        (@callback ||= Callback.create).public_send("#{on}=", block)
      end

      alias inspecting calling

      attr_reader(*(ATTRIBUTES = %i[api template callback].freeze))

      def self.extended(base)
        super

        ATTRIBUTES.each do |attr|
          base.define_method(attr) { self.class.public_send(attr) }
        end
      end
    end
  end
end
