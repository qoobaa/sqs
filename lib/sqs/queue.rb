module Sqs
  class Queue
    extend Forwardable

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
      create_message("MessageBody" => body)
      true
    end

    def message(visibility_timeout = nil)
      options = {}
      options["VisibilityTimeout"] = visibility_timeout.to_s if visibility_timeout
      receive_message(options)
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

    def create_message(options)
      queue_request(options.merge("Action" => "SendMessage"))
    end

    def receive_message(options)
      response = queue_request(options.merge("Action" => "ReceiveMessage"))
      parse_receive_message_result(response.body).first
    end

    def parse_get_queue_attributes_result(xml_body)
      xml = XmlSimple.xml_in(xml_body)
      get_queue_attributes_result = xml["GetQueueAttributesResult"].first
      attributes = get_queue_attributes_result["Attribute"]
      attributes.inject({}) do |result, attribute|
        attribute_name = attribute["Name"].first
        attribute_value = attribute["Value"].first
        result[attribute_name] = attribute_value
        result
      end
    end

    def parse_receive_message_result(xml_body)
      xml = XmlSimple.xml_in(xml_body)
      receive_message_result = xml["ReceiveMessageResult"].first
      messages = receive_message_result["Message"]
      if messages
        messages.map do |message|
          message_id = message["MessageId"].first
          receipt_handle = message["ReceiptHandle"].first
          md5_of_body = message["MD5OfBody"].first
          body = message["Body"].first
          Message.send(:new, self, :id => message_id, :receipt_handle => receipt_handle, :body_md5 => md5_of_body, :body => body)
        end
      else
        []
      end
    end
  end
end
