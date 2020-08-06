# frozen_string_literal: true

module SMS
  module Provider
    # https://www.mutlucell.com.tr/api/
    class MutluCell < Base
      posting   endpoint: 'https://smsgw.mutlucell.com/smsgw-ws/sndblkex',
                header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze

      rendering content: <<~TEMPLATE
        <?xml version="1.0" encoding="UTF-8"?>
        <smspack ka="<%= user %>" pwd="<%= pass %>" org="<%= from %>" charset="turkish">
          <mesaj>
            <metin><%= body.encode(xml: :text) %></metin>
            <nums><%= to.join(',') %></nums>
          </mesaj>
        </smspack>
      TEMPLATE

      BODY_PATTERN = /
        [$]
        (?<message_id>[^#]+)
        [#]
        (?<consumed_credits>.+)
        /x.freeze

      ERROR_CODES  = {
        '20' => 'Post edilen xml eksik veya hatalı.',
        '21' => 'Kullanılan originatöre sahip değilsiniz',
        '22' => 'Kontörünüz yetersiz',
        '23' => 'Kullanıcı adı ya da parolanız hatalı.',
        '24' => 'Şu anda size ait başka bir işlem aktif.',
        '25' => 'SMSC Stopped (işlemi 1-2 dk sonra tekrar deneyin)',
        '30' => 'Hesap Aktivasyonu sağlanmamış'
      }.freeze

      def on_http_success(result)
        body = (result.response.body&.to_s || '').strip

        if (m = body.match(BODY_PATTERN))
          result.detail.message_id       = m[:message_id]
          result.detail.consumed_credits = m[:consumed_credits]
        elsif ERROR_CODES.key? body
          result.error = ERROR_CODES[body]
        else
          result.error = 'Unknown'
        end
      end
    end
  end
end
