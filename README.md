`SMS`
=====

# Kullanım

Yapılandırma

```ruby
SMS.configure provider: :mutlu_cell,
              user:     'cezmi',
	      pass:     'secret',
	      from:     'OMUBAUM',
	      title:    'Ondokuz Mayıs Üniversitesi' # isteğe bağlı
```

Nokul'da yapılandırma

```ruby
SMS.configure(**Nokul::Tenant.credentials.sms.to_h)
```

Gönderim

```ruby
SMS.(to: %w[1234567 7654321], body: 'foo bar baz')
```

Yapılandırmadan ön tanımlı gelen `from` alanını değiştir

```ruby
SMS.(to: %w[1234567 7654321], body: 'foo bar baz', from 'OMUUZEM')
```

Yapılandırmadan ön tanımlı gelen `date` alanını değiştir

```ruby
SMS.(to: %w[1234567 7654321], body: 'foo bar baz', date: '02/08/2020 01:53')
```

Yapılandırmasız şekilde her şeyi açık ver

```ruby
SMS.(provider: :verimor,
     user:     'cezmi',
     pass:     'secret',
     from:     'OMUBAUM',
     to:       '1234567', # tek numara da olabilir
     date:     '02/08/2020 01:53',
     body:     'foo bar baz')
```

# Geliştirme

Örneğin `Acme` adında yeni bir SMS sağlayıcı için `provider` dizininde
`acme.rb` isimli bir sürücü oluştur.

```ruby
module SMS
  module Provider
    class Acme < Base
      posting   endpoint: 'https://example.com/send'
                header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze

      rendering content:  <<~TEMPLATE
        <?xml version="1.0" encoding="UTF-8"?>
	...
      TEMPLATE
    end
  end
end
```

Bu örnekte görülen `TEMPLATE` API isteklerinde render edilerek POST edilen bir
ERB şablonudur.  Şablonda (öncelik sırasıyla) `message` nesnesi ve `Provider`
yapılandırmasında tanımlı tüm nitelikleri kullanabilirsiniz.

Asgari olarak tüm sağlayıcılarda `user`, `pass` ve `from` (öntanımlı değer
olarak) yapılandırılmış olmalıdır.  Sağlayıcı bunun dışında bir nitelik,
örneğin `customer_no` gerektiriyorsa aşağıdaki örnekten yararlanabilirsiniz.

```ruby
module SMS
  module Provider
    class Acme < Base
      posting   endpoint: 'https://example.com/send'
                header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze

      rendering required: %i[customer_no], content:  <<~TEMPLATE
        <?xml version="1.0" encoding="UTF-8"?>
	<sms customer=<%= customer_no %>>
	...
	</sms>
      TEMPLATE
    end
  end
end
```

Sağlayıcıya veri gönderilirken farklı bir HTTP seçeneğine ihtiyaç duyarsanız
`options` seçeneğini ayarlayın.

```ruby
module SMS
  module Provider
    class Acme < Base
      posting   endpoint: 'https://example.com/send'
                header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze
		options:  { ssl_version: :TLSv1_2 }.freeze

      rendering content:  <<~TEMPLATE
        <?xml version="1.0" encoding="UTF-8"?>
	...
      TEMPLATE
    end
  end
end
```
