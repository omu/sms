# frozen_string_literal: true

require 'test_helper'

class VatanSmsTest < Minitest::Test
  include BasicSuite.new(
    provider: :vatan_sms,
    inset:    {
      single: <<~BODY,
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
      BODY
      multi:  <<~BODY
        <?xml version="1.0" encoding="UTF-8"?>
        <sms>
          <kno>NO</kno>
          <kulad>USER</kulad>
          <sifre>PASS</sifre>
          <gonderen>FROM</gonderen>
          <mesaj>BODY</mesaj>
          <numaralar>TO1,TO2</numaralar>
          <tur>Turkce</tur>
        </sms>
      BODY
    },
    outset:   {
      success: '1:261799963:Gonderildi:1:0.0084:8'
    }
  )
end
