# frozen_string_literal: true

require 'test_helper'

class MutluCellTest < Minitest::Test
  include BasicSuite.new(
    provider: :mutlu_cell,
    inset:    {
      single: <<~BODY,
        <?xml version="1.0" encoding="UTF-8"?>
        <smspack ka="USER" pwd="PASS" org="FROM" charset="turkish">
          <mesaj>
            <metin>BODY</metin>
            <nums>TO</nums>
          </mesaj>
        </smspack>
      BODY
      multi:  <<~BODY
        <?xml version="1.0" encoding="UTF-8"?>
        <smspack ka="USER" pwd="PASS" org="FROM" charset="turkish">
          <mesaj>
            <metin>BODY</metin>
            <nums>TO1,TO2</nums>
          </mesaj>
        </smspack>
      BODY
    },
    outset:   {
      success: '$123#19'
    }
  )
end
