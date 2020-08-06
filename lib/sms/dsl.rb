# frozen_string_literal: true

module SMS
  module DSL
    attr_reader :api, :templates

    def posting(endpoint:, header: {}, options: {})
      @api = API.new endpoint: endpoint, header: header, options: options
    end

    ALWAYS_REQUIRED = %i[
      from
      pass
      user
    ].freeze

    def rendering(label = :default, required: [], content:)
      (@templates ||= {})[label.to_sym] = Template.new(label:    label,
                                                       required: [*ALWAYS_REQUIRED, *required].uniq,
                                                       content:  content)
    end

    API      = Struct.new :endpoint, :header, :options, keyword_init: true

    Template = Struct.new :label, :required, :content, keyword_init: true do
      def config_class
        Structable.build(required: required)
      end

      def to_s
        content
      end
    end
  end
end
