module Sqs
  class Queue
    extend Forwardable
    include Parser

    attr_reader :path, :name, :service
    def_instance_delegators :service, :service_request
    private_class_method :new

    def ==(other)
      self.name == other.name and self.service == other.service
    end

    def destroy
      delete_queue
      true
    end

    def attributes
      get_queue_attributes
    end

    def update_attributes(attributes)
      set_queue_attributes(attributes)
      true
    end

    def create_message(body)
      send_message("MessageBody" => body)
      true
    end

    def message(visibility_timeout = nil)
      options = {}
      options["VisibilityTimeout"] = visibility_timeout.to_s if visibility_timeout
      receive_message(options).first
    end

    def inspect #:nodoc:
      "#<#{self.class}:#{name}>"
    end

    private

    def initialize(service, url) #:nodoc:
      self.service = service
      self.url = url
    end

    attr_writer :service, :path

    def url=(url)
      parsed_url = URI.parse(url)
      self.path = parsed_url.path[1..-1]
      self.name = parsed_url.path.split("/").last
    end

    def name=(name)
      @name = name
    end

    def queue_request(options = {})
      service_request(options.merge(:path => path))
    end

    def delete_queue
      queue_request("Action" => "DeleteQueue")
    end

    def get_queue_attributes
      response = queue_request("Action" => "GetQueueAttributes", "AttributeName" => "All")
      parse_get_queue_attributes_result(response.body)
    end

    def set_queue_attributes(options)
      attributes = {}
      options.each_with_index do |attribute, i|
        attributes["Attribute.#{i + 1}.Name"] = attribute.first.to_s
        attributes["Attribute.#{i + 1}.Value"] = attribute.last.to_s
      end
      queue_request(attributes.merge("Action" => "SetQueueAttributes"))
    end

    def send_message(options)
      queue_request(options.merge("Action" => "SendMessage"))
    end

    def receive_message(options)
      response = queue_request(options.merge("Action" => "ReceiveMessage"))
      parse_receive_message_result(response.body).map do |message_attributes|
        Message.send(:new, self, message_attributes)
      end
    end
  end
end
