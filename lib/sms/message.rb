# frozen_string_literal: true

module SMS
  class Message
    include Structable.(:from, :to, :body, :date)

    def before_initialize
      self.date = Time.current.strftime('%d/%m/%Y %H:%M')
    end

    def after_initialize
      self.to = Array(to)

      present! except: %i[from]
    end

    def to_h
      super.compact
    end
  end
end
