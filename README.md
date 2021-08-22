`SMS`
=====

[![Beta](https://omu.sh/assets/badge/beta.svg)](https://omu.sh "BAUM Beta")
[![](https://github.com/omu/sms/workflows/test/badge.svg)](https://github.com/omu/sms/actions)

# Kurulum

```sh
gem install omu-sms
```

# Kullanım

Yapılandırma

```ruby
OMU::SMS.configure provider: :mutlu_cell,
                   user:     'cezmi',
                   pass:     'secret',
                   from:     'OMUBAUM',
                   title:    'Ondokuz Mayıs Üniversitesi' # isteğe bağlı
```

Gönderim

```ruby
OMU::SMS.(to: %w[1234567 7654321], body: 'foo bar baz')
```

Yapılandırmadan ön tanımlı gelen `from` alanını değiştir

```ruby
OMU::SMS.(to: %w[1234567 7654321], body: 'foo bar baz', from 'OMUUZEM')
```

Yapılandırmadan ön tanımlı gelen `date` alanını değiştir

```ruby
OMU::SMS.(to: %w[1234567 7654321], body: 'foo bar baz', date: '02/08/2020 01:53')
```

Yapılandırmasız şekilde her şeyi açık ver

```ruby
OMU::SMS.(provider: :verimor,
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
module OMU
  module SMS
    module Provider
      class Acme < Base
        posting    endpoint: 'https://example.com/send',
                   header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze
  
        rendering  content:  <<~TEMPLATE
          <?xml version="1.0" encoding="UTF-8"?>
          ...
        TEMPLATE
  
        inspecting do |result|
          result.detail.credits = result.response.body&.to_s
        end
      end
    end
  end
end
```

Bu örnekte görülen `TEMPLATE` API isteklerinde render edilerek POST edilen bir
ERB şablonudur.  Şablonda (öncelik sırasıyla) `message` nesnesi ve `Provider`
yapılandırmasında tanımlı tüm nitelikleri kullanabilirsiniz. Örnekte
`inspecting` ile (istisna üretmeden sonlanan) başarılı bir POST işlemi
sonrasında çalıştırılacak bir callback ayarlanır.  Bu callback her sağlayıcı
tarafından gerçeklenmelidir.

Asgari olarak tüm sağlayıcılarda `user`, `pass` ve `from` (öntanımlı değer
olarak) yapılandırılmış olmalıdır.  Sağlayıcı bunun dışında bir nitelik,
örneğin `customer_no` gerektiriyorsa aşağıdaki örnekten yararlanabilirsiniz.

```ruby
module OMU
  module SMS
    module Provider
      class Acme < Base
        posting    endpoint: 'https://example.com/send',
                   header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze
  
        rendering  required: %i[customer_no], content:  <<~TEMPLATE
          <?xml version="1.0" encoding="UTF-8"?>
          <sms customer=<%= customer_no %>>
          ...
          </sms>
        TEMPLATE
  
        inspecting do |result|
          result.detail.credits = result.response.body&.to_s
        end
      end
    end
  end
end
```

Sağlayıcıya veri gönderilirken farklı bir HTTP seçeneğine ihtiyaç duyarsanız
`options` seçeneğini ayarlayın.

```ruby
module OMU
  module SMS
    module Provider
      class Acme < Base
        posting    endpoint: 'https://example.com/send',
                   header:   { 'content-type' => 'text/xml;charset=utf-8', 'accept' => 'xml' }.freeze,
                   options:  { ssl_version: :TLSv1_2 }.freeze
  
        rendering  content:  <<~TEMPLATE
          <?xml version="1.0" encoding="UTF-8"?>
          ...
        TEMPLATE
  
        inspecting do |result|
          result.detail.credits = result.response.body&.to_s
        end
      end
    end
  end
end
```

# Sürümleme

Tüm değişiklikler tamamlandıktan sonra:

1. Lint ve Test

   ```sh
   bundle exec rake lint
   bundle exec rake test
   ```

   Varsa hataları düzelt

2. Komitle

   ```sh
   git commit -a
   git push origin master
   ```

   CI'da hata varsa düzeltinceye kadar devam et

3. Sürüm yükselt

   ```sh
   $EDITOR lib/omu/sms/version.rb
   git commit -a -m "Yeni sürüm: «sürüm»"
   git push origin master
   ```

4. Etiketle

   ```sh
   git tag -a «sürüm» -m «sürüm»
   git push --tags origin
   ```

5. Paketle

   ```sh
   bundle exec rake package
   ```
