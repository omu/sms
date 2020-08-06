# frozen_string_literal: true

module SMS
  module Provider
    class MutluCell < Base
      posting   endpoint: 'https://smsgw.mutlucell.com/smsgw-ws/sndblkex',
                header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze

      rendering content: <<~TEMPLATE
        <?xml version="1.0" encoding="UTF-8"?>
        <smspack ka="<%= user %>" pwd="<%= pass %>" org="<%= from %>" charset="turkish" >
          <mesaj>
            <metin><%= body.encode(xml: :text) %></metin>
            <nums><%= to.join(',') %></nums>
          </mesaj>
        </smspack>
      TEMPLATE
    end
  end
end
