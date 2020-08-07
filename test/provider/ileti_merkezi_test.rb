# frozen_string_literal: true

require 'test_helper'
require 'open3'

class IletiMerkeziTest < Minitest::Test
  PROVIDER = :ileti_merkezi
  ENDPOINT = SMS::Provider.provider(PROVIDER).api.endpoint
  POST     = <<~POST
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
  POST

  def setup
    WebMock.enable!
    WebMock.stub_request(:post, ENDPOINT).to_return status: 200, body: <<~BODY
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
  end

  def teardown
    SMS.unconfigure
    WebMock.reset_executed_requests!
    WebMock.disable!
  end

  def test_when_default
    SMS.configure(**dummy, provider: PROVIDER)
    SMS.(to: 'TO', body: 'BODY', date: 'DATE')
    WebMock.assert_requested :post, ENDPOINT, body: POST
  end

  def test_when_not_default
    SMS.(provider: PROVIDER, user: 'USER', pass: 'PASS', from: 'FROM', to: 'TO', body: 'BODY', date: 'DATE')
    WebMock.assert_requested :post, ENDPOINT, body: POST
  end

  def test_multiple_receipents
    SMS.configure(**dummy, provider: PROVIDER)
    SMS.(to: %w[TO1 TO2], body: 'NEW_BODY', date: 'DATE')
    WebMock.assert_requested :post, ENDPOINT, body: <<~POST
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
            <text><![CDATA[NEW_BODY]]></text>
            <receipents>
              <number>TO1</number>
              <number>TO2</number>
            </receipents>
          </message>
        </order>
      </request>
    POST
  end

  def test_validate_xml
    skip 'xmllint required (libxml2-utils package)' if `which xmllint`.empty?

    _, _, status = Open3.capture3('xmllint --noout /dev/stdin', stdin_data: POST)
    assert status.success?
  end
end
