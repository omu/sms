# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'

require 'ostruct'
require 'active_support/all' # FIXME: Remove under Rails

require 'sms'

require 'webmock'
require 'webmock/test_unit'

def dummy(**args)
  {
    user: 'USER',
    pass: 'PASS',
    from: 'FROM',
    no:   'NO',
    to:   'TO',
    body: 'BODY'
  }.merge(**args)
end
