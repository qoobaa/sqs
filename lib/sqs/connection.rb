module Sqs

  # Class responsible for handling connections to amazon hosts
  class Connection
    attr_accessor :access_key_id, :secret_access_key, :use_ssl, :timeout, :debug
    alias :use_ssl? :use_ssl

    # ==== Parameters:
    # +options+:: Hash of options
    #
    # ==== Options:
    # +access_key_id+:: access key id
    # +secret_access_key+:: secret access key
    # +use_ssl+:: optional, defaults to false
    # +debug+:: optional, defaults to false
    # +timeout+:: optional, for Net::HTTP
    def initialize(options = {})
      @access_key_id = options[:access_key_id]
      @secret_access_key = options[:secret_access_key]
      @use_ssl = options[:use_ssl] || false
      @debug = options[:debug]
      @timeout = options[:timeout]
    end

    # Makes request with given HTTP method, sets missing parameters,
    # adds signature to request header and returns response object
    # (Net::HTTPResponse)
    #
    # ==== Parameters:
    # +options+:: hash of options
    #
    # ==== Options:
    # +host+:: hostname to connect to, optional, defaults to queue.amazonaws.com
    # +path+:: path to send request to, required, throws ArgumentError if not given
    #
    # ==== Returns:
    # Net::HTTPResponse object -- response from remote server
    def request(options)
      host = options.delete(:host) || HOST
      path = options.delete(:path) or raise ArgumentError, "No path given"

      request = Net::HTTP::Post.new(path)

      response = http(host).start do |http|
        add_common_options!(options)
        add_timestamp!(options)
        add_signature!(host, path, options)

        request.set_form_data(options)

        http.request(request)
      end

      handle_response(response)
    end

    private

    def add_common_options!(options)
      options.merge!("AWSAccessKeyId"   => access_key_id,
                     "SignatureMethod"  => "HmacSHA256",
                     "SignatureVersion" => "2",
                     "Version"          => "2009-02-01")
    end

    def add_timestamp!(options)
      options["Timestamp"] = Time.now.utc.iso8601 if options["Timestamp"].nil? and options["Expires"].nil?
    end

    def add_signature!(host, path, options)
      options["Signature"] = Signature.generate(:method => :post,
                                                :host => host,
                                                :path => path,
                                                :access_key_id => access_key_id,
                                                :secret_access_key => secret_access_key,
                                                :params => options)
    end

    def port
      use_ssl ? 443 : 80
    end

    def http(host)
      http = Net::HTTP.new(host, port)
      http.set_debug_output(STDOUT) if @debug
      http.use_ssl = @use_ssl
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @use_ssl
      http.read_timeout = @timeout if @timeout
      http
    end

    def handle_response(response)
      case response.code.to_i
      when 200...300
        response
      when 300...600
        if response.body.nil? || response.body.empty?
          raise Error::ResponseError.new(nil, response)
        else
          xml = XmlSimple.xml_in(response.body)
          message = xml["Error"].first
          code = xml["Error"].first["Code"].first.split(".").last
          raise Error::ResponseError.exception(code).new(message, response)
        end
      else
        raise(ConnectionError.new(response, "Unknown response code: #{response.code}"))
      end
      response
    end
  end
end
