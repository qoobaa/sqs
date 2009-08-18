module Sqs
  class Service
    extend Roxy::Moxie
    include Parser

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
      @access_key_id = options[:access_key_id] or raise ArgumentError, "No access key id given"
      @secret_access_key = options[:secret_access_key] or raise ArgumentError, "No secret access key given"
      @use_ssl = options[:use_ssl]
      @timeout = options[:timeout]
      @debug = options[:debug]
    end

    # Returns all queues in the service and caches the result (see reload)
    def queues(reload = false)
      if reload or @queues.nil?
        @queues = list_queues
      else
        @queues
      end
    end

    proxy :queues do
      # Builds new queue with given name
      def create(name, default_visibility_timeout = nil)
        options = { "QueueName" => name }
        options["DefaultVisibilityTimeout"] = default_visibility_timeout.to_s if default_visibility_timeout
        proxy_owner.send(:create_queue, options)
      end

      # Finds the queue with given name
      def find_first(name)
        find_all(name).first
      end
      alias :find :find_first

      # Find all queues in the service
      def find_all(name)
        if name and not name.empty?
          proxy_owner.send(:list_queues, "QueueNamePrefix" => name)
        else
          proxy_target
        end
      end

      # Reloads the queue list (clears the cache)
      def reload
        proxy_owner.queues(true)
      end

      # Destroy all queues in the service (USE WITH CARE!).
      def destroy_all
        proxy_target.each { |queue| queue.destroy }
        true
      end
    end

    def inspect #:nodoc:
      "#<#{self.class}:#@access_key_id>"
    end

    private

    def list_queues(options = {})
      response = service_request(options.merge("Action" => "ListQueues"))

      parse_list_queues_result(response.body).map do |url|
        Queue.send(:new, self, url)
      end
    end

    def create_queue(options)
      name = options["QueueName"]
      raise ArgumentError, "Invalid queue name: #{name}" unless queue_name_valid?(name)

      response = service_request(options.merge("Action" => "CreateQueue"))

      url = parse_create_queue_result(response.body)
      Queue.send(:new, self, url)
    end

    def queue_name_valid?(name)
      name =~ /\A[a-zA-Z0-9_-]{1,80}\Z/
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
  end
end
