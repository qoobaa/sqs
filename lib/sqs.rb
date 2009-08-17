require "time"
require "openssl"
require "net/http"
require "net/https"
require "base64"
require "forwardable"

require "xmlsimple"

require "sqs/roxy/proxy"
require "sqs/roxy/moxie"

require "sqs/connection"
require "sqs/exceptions"
require "sqs/message"
require "sqs/queue"
require "sqs/service"
require "sqs/signature"

module Sqs
  # Default (and only) host serving SQS stuff
  HOST = "queue.amazonaws.com"
end
