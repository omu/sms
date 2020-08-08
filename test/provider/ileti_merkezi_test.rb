# frozen_string_literal: true

require 'test_helper'

class IletiMerkeziTest < Minitest::Test
  include BasicSuite.new(
    provider: :ileti_merkezi,
    inset:    {
      single: <<~BODY,
        <?xml version="1.0" encoding="UTF-8"?>
        <request>
          <authentication>
            <username>USER</username>
            <password>PASS</password>
          </authentication>
          <order>
            <sender>FROM</sender>
            <sendDateTime>DATE</sendDateTime>
            <message>
              <text><![CDATA[BODY]]></text>
              <receipents>
                <number>TO</number>
              </receipents>
            </message>
          </order>
        </request>
      BODY
      multi:  <<~BODY
        <?xml version="1.0" encoding="UTF-8"?>
        <request>
          <authentication>
            <username>USER</username>
            <password>PASS</password>
          </authentication>
          <order>
            <sender>FROM</sender>
            <sendDateTime>DATE</sendDateTime>
            <message>
              <text><![CDATA[BODY]]></text>
              <receipents>
                <number>TO1</number>
                <number>TO2</number>
              </receipents>
            </message>
          </order>
        </request>
      BODY
    },
    outset:   {
      success: <<~BODY
        <?xml version="1.0" encoding="UTF-8"?>
        <response>
          <status>
            <code>200</code>
            <message>İşlem başarılı</message>
          </status>
          <order>
            <id>123</id>
          </order>
        </response>
      BODY
    }
  )
end
