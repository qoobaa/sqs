module Sqs
  class Service
    extend Roxy::Moxie

    attr_reader :access_key_id, :secret_access_key, :use_ssl

    # Compares service to other, by access_key_id and secret_access_key
    def ==(other)
      self.access_key_id == other.access_key_id and self.secret_access_key == other.secret_access_key
    end

    # ==== Parameters:
    # +options+:: a hash of options described below
    #
    # ==== Options:
    # +access_key_id+:: Amazon access key id, required
    # +secret_access_key+:: Amazon secret access key, required
    # +use_ssl+:: true if use ssl in connection, otherwise false
    # +timeout+:: parameter for Net::HTTP module
    # +debug+:: prints the raw requests to STDOUT
    def initialize(options)
      @access_key_id = options[:access_key_id] or raise ArgumentError.new("No access key id given")
      @secret_access_key = options[:secret_access_key] or raise ArgumentError.new("No secret access key given")
      @use_ssl = options[:use_ssl]
      @timeout = options[:timeout]
      @debug = options[:debug]
    end

    # Returns all queues in the service and caches the result (see reload)
    def queues(reload = false)
      if reload or @queues.nil?
        response = service_request(:params => { "Action" => "ListQueues" })
        @queues = parse_queues(response.body)
      else
        @queues
      end
    end

    # Returns "http://" or "https://", depends on use_ssl value from initializer
    def protocol
      use_ssl ? "https://" : "http://"
    end

    # Return 443 or 80, depends on use_ssl value from initializer
    def port
      use_ssl ? 443 : 80
    end

    proxy :queues do
      # Builds new queue with given name
      def create(name, default_visibility_timeout = nil)
        url = proxy_owner.send(:create_queue, name, default_visibility_timeout)
        Queue.new(proxy_owner, url)
      end

      # Finds the queue with given name
      def find_first(name)
        queue = build(name)
        queue.retrieve
      end
      alias :find :find_first

      # Find all queues in the service
      def find_all
        proxy_target
      end

      # Reloads the queue list (clears the cache)
      def reload
        proxy_owner.queues(true)
      end

      # Destroy all queues in the service. Doesn't destroy non-empty
      # queues by default, pass true to force destroy (USE WITH
      # CARE!).
      def destroy_all(force = false)
        proxy_target.each do |queue|
          queue.destroy(force)
        end
      end
    end

    def inspect #:nodoc:
      "#<#{self.class}:#@access_key_id>"
    end

    private

    def create_queue(name, default_visibility_timeout = nil)
      params = {
        "Action" => "CreateQueue",
        "QueueName" => name,
      }
      params["DefaultVisibilityTimeout"] = default_visibility_timeout if default_visibility_timeout
      service_request({ :params => params })
    end

    def service_request(options = {})
      connection.request(options.merge(:path => "/#{options[:path]}"))
    end

    def connection
      if @connection.nil?
        @connection = Connection.new
        @connection.access_key_id = @access_key_id
        @connection.secret_access_key = @secret_access_key
        @connection.use_ssl = @use_ssl
        @connection.timeout = @timeout
        @connection.debug = @debug
      end
      @connection
    end

    def parse_queues(xml_body)
      xml = XmlSimple.xml_in(xml_body)
      queues = xml["ListQueuesResult"]
      if queues
        queues_names = queues.map { |queue| queue["QueueUrl"].first }
        queues_names.map do |queue_name|
          Queue.new(self, queue_name)
        end
      else
        []
      end
    end
  end
end
