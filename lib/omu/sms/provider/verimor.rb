# frozen_string_literal: true

# TODO: Untested, unfinished

module OMU::SMS
  module Provider
    # https://github.com/verimor/SMS-API/blob/master/user_guide.md#sms-g%C3%B6nderi%CC%87mi%CC%87
    class Verimor < Base
      posting   endpoint: 'https://sms.verimor.com.tr/v2/send.json',
                header:   { 'content-type' => 'application/json;charset=utf-8', 'accept' => '*/*' }.freeze

      rendering content: <<~TEMPLATE
        {
          "username"   : "<%= user %>",
          "password"   : "<%= pass %>",
          "source_addr": "<%= from %>",
          "messages"   : [
            {#{' '}
              "msg" : "<%= body %>",
              "dest": "<%= to.join(',') %>"
            }
          ]
        }
      TEMPLATE

      inspecting do
        # TODO: implement
      end
    end
  end
end
