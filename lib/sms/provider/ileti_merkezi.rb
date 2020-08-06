# frozen_string_literal: true

module SMS
  module Provider
    # https://a2psmsapi.com/?ref=iletimerkezicom#apidoc
    class IletiMerkezi < Base
      posting   endpoint: 'https://api.iletimerkezi.com/v1/send-sms',
                header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze

      rendering content: <<~TEMPLATE
        <?xml version="1.0" encoding="UTF-8"?>
        <request>
          <authentication>
            <username><%= user %></username>
            <password><%= pass %></password>
          </authentication>
          <order>
            <sender><%= from %></sender>
            <sendDateTime><%= date %></sendDateTime>
            <message>
              <text><![CDATA[<%= body %>]]></text>
              <receipents>
                <%- to.each do |receipent| -%>
                <number><%= receipent %></number>
                <%- end -%>
              </receipents>
            </message>
          </order>
        </request>
      TEMPLATE

      responding on: :success do
      end
    end
  end
end
