module Sqs
  class Queue
    extend Roxy::Moxie
    extend Forwardable

    attr_reader :path, :name, :service

    def_instance_delegators :service, :service_request

    def retrieve
      queue_request(:get, :params => { :max_keys => 0 })
      self
    end

    def ==(other)
      self.name == other.name and self.service == other.service
    end

    def destroy(force)
      queue_request(:delete)
      true
    end

    def inspect #:nodoc:
      "#<#{self.class}:#{name}>"
    end

    def initialize(service, url) #:nodoc:
      self.service = service
      self.url = url
    end

    private

    attr_writer :service, :path

    def url=(url)
      parsed_url = URI.parse(url)
      self.path = parsed_url.path[1..-1]
      self.name = parsed_url.path.split("/").last
    end

    def name=(name)
      raise ArgumentError.new("Invalid queue name: #{name}") unless name_valid?(name)
      @name = name
    end

    def queue_request(method, options = {})
      service_request(method, options.merge(:host => host, :path => path))
    end

    def name_valid?(name)
      name =~ /\A[a-z0-9][a-z0-9\._-]{2,254}\Z/ and name !~ /\A#{URI::REGEXP::PATTERN::IPV4ADDR}\Z/
    end
  end
end
