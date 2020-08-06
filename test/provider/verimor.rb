# frozen_string_literal: true

require 'test_helper'
require 'open3'

class VerimorTest < Minitest::Test
  PROVIDER = :verimor
  ENDPOINT = SMS::Provider.provider(PROVIDER).api.endpoint
  POST     = <<~POST
    {
      "username"   : "USER",
      "password"   : "PASS",
      "source_addr": "FROM",
      "messages"   : [
        { 
          "msg" : "BODY",
          "dest": "TO"
        }
      ]
    }
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
      {
        "username"   : "USER",
        "password"   : "PASS",
        "source_addr": "FROM",
        "messages"   : [
          { 
            "msg" : "NEW_BODY",
            "dest": "TO1,TO2"
          }
        ]
      }
    POST
  end

  def test_validate_json
    JSON.parse(POST)
  end
end
