# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
require 'omu/sms/version'

Gem::Specification.new do |spec|
  spec.author                = 'OMU BAUM Crew'
  spec.description           = 'Send SMS'
  spec.email                 = 'contact@baum.omu.edu.tr'
  spec.files                 = ['README.md', 'LICENSE.md', 'Rakefile']
  spec.homepage              = 'https://omu.sh'
  spec.license               = 'GPL-3.0'
  spec.name                  = 'omu-sms'
  spec.required_ruby_version = '>= 2.5'
  spec.summary               = 'Send SMS through various SMS providers (mostly in Turkey)'
  spec.version               = OMU::SMS::VERSION
end
