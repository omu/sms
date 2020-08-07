# frozen_string_literal: true

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

    def (Callback = Struct.new(:success, :failure, :init, keyword_init: true)).create
      empty = proc {}

      new success: empty, failure: empty, init: empty
    end

    attr_reader :api, :template, :callback

    def posting(endpoint:, header: {}, options: {})
      @api = API.new endpoint: endpoint, header: header, options: options
    end

    ALWAYS_REQUIRED = %i[
      from
      pass
      user
    ].freeze

    def rendering(required: [], content:)
      @template = Template.new(required: [*ALWAYS_REQUIRED, *required].uniq, content: content)
    end

    def calling(on: :success, &block)
      (@callback ||= Callback.create).public_send("#{on}=", block)
    end

    alias inspecting calling
  end
end
