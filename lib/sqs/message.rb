module Sqs
  class Message
    extend Forwardable

    def_instance_delegators :queue, :name, :queue_request

    attr_reader :queue, :id, :body, :body_md5, :receipt_handle

    def ==(other)
      self.id == other.id and self.queue == other.queue
    end

    def destroy
      queue_request(:params => { "Action" => "DeleteMessage", "ReceiptHandle" => receipt_handle })
      true
    end

    def initialize(queue, options)
      @queue = queue
      @id = options[:id]
      @body = options[:body]
      @body_md5 = options[:body_md5]
      @receipt_handle = options[:receipt_handle]
    end

    def inspect #:nodoc:
      "#<#{self.class}:#{name}/#{id}>"
    end
  end
end
