# frozen_string_literal: true

require 'test_helper'
require 'open3'

class MutluCellTest < Minitest::Test
  PROVIDER = :mutlu_cell
  ENDPOINT = SMS::Provider.provider(PROVIDER).api.endpoint
  POST     = <<~POST
    <?xml version="1.0" encoding="UTF-8"?>
    <smspack ka="USER" pwd="PASS" org="FROM" charset="turkish" >
      <mesaj>
        <metin>BODY</metin>
        <nums>TO</nums>
      </mesaj>
    </smspack>
  POST

  def setup
    WebMock.enable!
    WebMock.stub_request(:post, ENDPOINT)
  end

  def teardown
    SMS.unconfigure
    WebMock.reset_executed_requests!
    WebMock.disable!
  end

  def test_when_default
    SMS.configure(**dummy, provider: PROVIDER)
    SMS.(to: 'TO', body: 'BODY')
    WebMock.assert_requested :post, ENDPOINT, body: POST
  end

  def test_when_not_default
    SMS.(provider: PROVIDER, user: 'USER', pass: 'PASS', from: 'FROM', to: 'TO', body: 'BODY')
    WebMock.assert_requested :post, ENDPOINT, body: POST
  end

  def test_multiple_receipents
    SMS.configure(**dummy, provider: PROVIDER)
    SMS.(to: %w[TO1 TO2], body: 'NEW_BODY')
    WebMock.assert_requested :post, ENDPOINT, body: <<~POST
      <?xml version="1.0" encoding="UTF-8"?>
      <smspack ka="USER" pwd="PASS" org="FROM" charset="turkish" >
        <mesaj>
          <metin>NEW_BODY</metin>
          <nums>TO1,TO2</nums>
        </mesaj>
      </smspack>
    POST
  end

  def test_validate_xml
    skip 'xmllint required (libxml2-utils package)' if `which xmllint`.empty?

    _, _, status = Open3.capture3('xmllint --noout /dev/stdin', stdin_data: POST)
    assert status.success?
  end
end
