module Sqs
  class Queue
    extend Forwardable

    attr_reader :path, :name, :service

    def_instance_delegators :service, :service_request

    def ==(other)
      self.name == other.name and self.service == other.service
    end

    def destroy
      queue_request({ :params => { "Action" => "DeleteQueue" } })
      true
    end

    def attributes
      response = queue_request({ :params => { "Action" => "GetQueueAttributes", "AttributeName" => "All" }})
      parse_get_queue_attributes_result(response.body)
    end

    def update_attributes(attributes)
      set_attributes = {}
      attributes.each_with_index do |attribute, i|
        set_attributes["Attribute.#{i + 1}.Name"] = attribute.first.to_s
        set_attributes["Attribute.#{i + 1}.Value"] = attribute.last.to_s
      end
      response = queue_request(:params => set_attributes.merge("Action" => "SetQueueAttributes"))
    end

    def create_message(body)
      response = queue_request(:params => { "Action" => "SendMessage", "MessageBody" => body })
    end

    def message
      response = queue_request(:params => { "Action" => "ReceiveMessage" })
      parse_receive_message_result(response.body).first
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

    def queue_request(options = {})
      service_request(options.merge(:path => path))
    end

    def name_valid?(name)
      name =~ /[a-zA-Z0-9_-]{1,80}/
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
          Message.new(self, :id => message_id, :receipt_handle => receipt_handle, :body_md5 => md5_of_body, :body => body)
        end
      else
        []
      end
    end
  end
end
