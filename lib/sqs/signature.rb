module Sqs

  # Class responsible for generating signatures to requests.
  #
  # Implements algorithm defined by Amazon Web Services to sign
  # request with secret private credentials

  class Signature
    UNSAFE_REGEXP = /[^a-zA-Z0-9_.-]/

    # Generates signature for given parameters
    #
    # ==== Parameters:
    # +options+: a hash that contains options listed below
    #
    # ==== Options:
    # +host+: hostname
    # +access_key_id+: access key id
    # +secret_access_key+: secret access key
    # +method+: method of the request ("GET" or "POST")
    # +params+: request parameters hash
    # +path+: request path
    #
    # ==== Returns:
    # Generated signature for given hostname and request
    def self.generate(options)
      host = options[:host]
      access_key_id = options[:access_key_id]
      secret_access_key = options[:secret_access_key]
      method = options[:method]
      params = options[:params]
      path = options[:path]

      string_to_sign = ""
      string_to_sign << method.to_s.upcase
      string_to_sign << "\n"
      string_to_sign << host.to_s.downcase
      string_to_sign << "\n"
      string_to_sign << path
      string_to_sign << "\n"
      string_to_sign << canonicalized_query_string(params)

      puts "*****"
      puts string_to_sign
      puts "*****"

      digest = OpenSSL::Digest::Digest.new("sha256")
      hmac = OpenSSL::HMAC.digest(digest, secret_access_key, string_to_sign)
      base64 = Base64.encode64(hmac)
      base64.chomp
    end

    private

    def self.canonicalized_query_string(params)
      results = params.sort.map do |param|
        urlencoded_key = URI.encode(param.first, UNSAFE_REGEXP)
        urlencoded_value = URI.encode(param.last, UNSAFE_REGEXP)
        "#{urlencoded_key}=#{urlencoded_value}"
      end
      results.join("&")
    end
  end
end
