module Sqs
  module Parser
    include REXML

    def parse_list_queues_result(xml)
      urls = []
      Document.new(xml).elements.each("ListQueuesResponse/ListQueuesResult/QueueUrl") { |e| urls << e.text }
      urls
    end

    def parse_create_queue_result(xml)
      Document.new(xml).elements["CreateQueueResponse/CreateQueueResult/QueueUrl"].text
    end

    def parse_get_queue_attributes_result(xml)
      attributes = {}
      Document.new(xml).elements.each("GetQueueAttributesResponse/GetQueueAttributesResult/Attribute") do |e|
        name = e.elements["Name"].text
        value = e.elements["Value"].text
        attributes[name] = value
      end
      attributes
    end

    def parse_receive_message_result(xml)
      messages = []
      Document.new(xml).elements.each("ReceiveMessageResponse/ReceiveMessageResult/Message") do |e|
        messages << {
          :id => e.elements["MessageId"].text,
          :receipt_handle => e.elements["ReceiptHandle"].text,
          :body_md5 => e.elements["MD5OfBody"].text,
          :body => e.elements["Body"].text
        }
      end
      messages
    end
  end
end
