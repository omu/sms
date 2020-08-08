# frozen_string_literal: true

require 'test_helper'

class VerimorTest < Minitest::Test
  include BasicSuite.new(
    provider: :verimor,
    inset:    {
      single: <<~BODY,
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
      BODY
      multi:  <<~BODY
        {
          "username"   : "USER",
          "password"   : "PASS",
          "source_addr": "FROM",
          "messages"   : [
            { 
              "msg" : "BODY",
              "dest": "TO1,TO2"
            }
          ]
        }
      BODY
    },
    outset:   {
      success: ''
    }
  )
end
