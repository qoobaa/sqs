module Sqs
  module Parser
    include REXML

    def rexml_document(xml)
      if xml.respond_to? :force_encoding
        if defined?(REXML::Encoding::UTF_8)
          xml.force_encoding(Encoding::UTF_8)
        else
          xml.force_encoding('utf-8')
        end
      end
      Document.new(xml)
    end

    def parse_list_queues_result(xml)
      urls = []
      rexml_document(xml).elements.each("ListQueuesResponse/ListQueuesResult/QueueUrl") { |e| urls << e.text }
      urls
    end

    def parse_create_queue_result(xml)
      rexml_document(xml).elements["CreateQueueResponse/CreateQueueResult/QueueUrl"].text
    end

    def parse_get_queue_attributes_result(xml)
      attributes = {}
      rexml_document(xml).elements.each("GetQueueAttributesResponse/GetQueueAttributesResult/Attribute") do |e|
        name = e.elements["Name"].text
        value = e.elements["Value"].text
        attributes[name] = value
      end
      attributes
    end

    def parse_receive_message_result(xml)
      messages = []
      rexml_document(xml).elements.each("ReceiveMessageResponse/ReceiveMessageResult/Message") do |e|
        messages << {
          :id => e.elements["MessageId"].text,
          :receipt_handle => e.elements["ReceiptHandle"].text,
          :body_md5 => e.elements["MD5OfBody"].text,
          :body => e.elements["Body"].text
        }
      end
      messages
    end

    def parse_error(xml)
      document = rexml_document(xml)
      [document.elements["ErrorResponse/Error/Code"].text.split(".").last, document.elements["ErrorResponse/Error/Message"].text]
    end
  end
end
