# frozen_string_literal: true

require 'test_helper'
require 'open3'

class VatanSmsTest < Minitest::Test
  PROVIDER = :vatan_sms
  ENDPOINT = SMS::Provider.provider(PROVIDER).api.endpoint
  POST     = <<~POST
    <?xml version="1.0" encoding="UTF-8"?>
    <sms>
      <kno>NO</kno>
      <kulad>USER</kulad>
      <sifre>PASS</sifre>
      <gonderen>FROM</gonderen>
      <mesaj>BODY</mesaj>
      <numaralar>TO</numaralar>
      <tur>Turkce</tur>
    </sms>
  POST

  def setup
    WebMock.enable!
    WebMock.stub_request(:post, ENDPOINT).to_return(body: '1:261799963:Gonderildi:1:0.0084:8', status: 200)
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
    SMS.(provider: PROVIDER, user: 'USER', pass: 'PASS', no: 'NO', from: 'FROM', to: 'TO', body: 'BODY')
    WebMock.assert_requested :post, ENDPOINT, body: POST
  end

  def test_multiple_receipents
    SMS.configure(**dummy, provider: PROVIDER)
    SMS.(to: %w[TO1 TO2], body: 'NEW_BODY')
    WebMock.assert_requested :post, ENDPOINT, body: <<~POST
      <?xml version="1.0" encoding="UTF-8"?>
      <sms>
        <kno>NO</kno>
        <kulad>USER</kulad>
        <sifre>PASS</sifre>
        <gonderen>FROM</gonderen>
        <mesaj>NEW_BODY</mesaj>
        <numaralar>TO1,TO2</numaralar>
        <tur>Turkce</tur>
      </sms>
    POST
  end

  def test_validate_xml
    skip 'xmllint required (libxml2-utils package)' if `which xmllint`.empty?

    _, _, status = Open3.capture3('xmllint --noout /dev/stdin', stdin_data: POST)
    assert status.success?
  end
end
