require "test_helper"

class SignatureTest < Test::Unit::TestCase
  def setup
    @options = {}
    @params = {}
    @options[:host] = "queue.amazonaws.com"
    @options[:path] = "/"
    @options[:method] = :get
    @options[:access_key_id] = "0PN5J17HBGZHT7JJ3X82"
    @options[:secret_access_key] = "uV3F3YluFJax1cknvbcGwgjvx4QpvB+leU8dUj2o"
    @params["SignatureMethod"] = "HmacSHA256"
    @params["SignatureVersion"] = "2"
    @params["Version"] = "2009-02-01"
    @params["Timestamp"] = "2009-08-17T08:56:12Z"
    @params["AWSAccessKeyId"] = @options[:access_key_id]
    @options[:params] = @params
  end

  def test_signature_for_get
    @options[:method] = :get
    expected = "lQcH/YUdHHpo4hshdHZrGbX9CLvksKmD9atmrCroyAo="
    actual = Sqs::Signature.generate(@options)
    assert_equal expected, actual
  end

  def test_signagure_for_post
    @options[:method] = :post
    expected = "st9O4GTVytI+5BjbjfRSPRB8xKOxel52F7Sle706BcA="
    actual = Sqs::Signature.generate(@options)
    assert_equal expected, actual
  end
end
