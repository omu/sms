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
    body: 'BODY',
    date: 'DATE',
    from: 'FROM',
    no:   'NO',
    pass: 'PASS',
    to:   'TO',
    user: 'USER'
  }.merge(**args)
end
