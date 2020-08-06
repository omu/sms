# frozen_string_literal: true

module SMS
  module Provider
    # https://www.vatansms.com/apidokuman/api-entegrasyon.pdf
    class VatanSms < Base
      posting   endpoint: 'https://panel.vatansms.com:80/panel/smsgonder1Npost.php',
                header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze

      rendering required: %i[no], content: <<~TEMPLATE
        <?xml version="1.0" encoding="UTF-8"?>
        <sms>
          <kno><%= no %></kno>
          <kulad><%= user %></kulad>
          <sifre><%= pass %></sifre>
          <gonderen><%= from %></gonderen>
          <mesaj><%= body %></mesaj>
          <numaralar><%= to.join(',') %></numaralar>
          <tur>Turkce</tur>
        </sms>
      TEMPLATE

      def on_http_succes(*)
        nil
      end
    end
  end
end
