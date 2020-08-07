# frozen_string_literal: true

module SMS
  module Provider
    # https://www.vatansms.com/apidokuman/api-entegrasyon.pdf
    #
    # "dh key too small" hatası için /etc/ssl/openssl.cnf dosyasında
    #
    # 	[system_default_sect]
    #   CipherString = DEFAULT@SECLEVEL=1
    #
    # DİKKAT!  Bu güvensiz bir ayardır; sağlayıcı SSL yapılandırmasını düzeltmeli.
    class VatanSms < Base
      posting   endpoint: 'https://www.oztekbayi.com/panel/smsgonder1Npost.php',
                header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze,
                options:  { ssl_version: :TLSv1_2 }.freeze

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

      inspecting do |result|
        # Example: 1:261799963:Gonderildi:1:0.0084:8
        fields = (result.response.body&.to_s || '').strip.split(':')

        if fields.size == 6
          result.detail.status_code       = code = fields.shift
          result.detail.transaction_id    = fields.shift
          result.detail.status_message    = fields.shift
          result.detail.receipents_number = fields.shift
          result.detail.payment           = fields.shift
          result.detail.message_length    = fields.shift

          result.error = "Unexpected status code: #{code}" unless code == '1'
        else
          result.detail.status_code       = fields.shift
          result.error                    = fields.join(':') || 'Unknown error'
        end
      end
    end
  end
end
