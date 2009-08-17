require 'rubygems'
require 'test/unit'
require 'rr'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sqs'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
