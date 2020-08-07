# frozen_string_literal: true

require 'rexml/document'

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

      RESPONSE_CODES = {
        '110' => 'Mesaj gönderiliyor',
        '111' => 'Mesaj gönderildi',
        '112' => 'Mesaj gönderilemedi',
        '113' => 'Siparişin gönderimi devam ediyor',
        '114' => 'Siparişin gönderimi tamamlandı',
        '115' => 'Sipariş gönderilemedi',
        '200' => 'İşlem başarılı',
        '400' => 'İstek çözümlenemedi',
        '401' => 'Üyelik bilgileri hatalı',
        '402' => 'Bakiye yetersiz',
        '404' => 'API istek yapılan yönteme sahip değil',
        '450' => 'Gönderilen başlık kullanıma uygun değil',
        '451' => 'Tekrar eden sipariş',
        '452' => 'Mesaj alıcıları hatalı',
        '453' => 'Sipariş boyutu aşıldı',
        '454' => 'Mesaj metni boş',
        '455' => 'Sipariş bulunamadı',
        '456' => 'Sipariş gönderim tarihi henüz gelmedi',
        '457' => 'Mesaj gönderim tarihinin formatı hatalı',
        '503' => 'Sunucu geçici olarak servis dışı'
      }.freeze

      inspecting do |result|
        doc  = REXML::Document.new(result.response.body&.to_s || '')
        code = doc.elements['response/status/code']&.first

        next (result.error = 'Undefined code') if code.nil? || (value = RESPONSE_CODES[code = code.to_s]).nil?

        if code == '200'
          order_id = doc.elements['response/order/id']&.first
          next (result.error = 'Undefined order id') if order_id.nil?

          result.detail.order_id = order_id
          result.detail.message  = value
        else
          result.error = value || 'Unknown'
        end
      rescue REXML::ParseException => e
        result.error = e.message
      end
    end
  end
end
