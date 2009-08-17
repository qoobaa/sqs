# stdlibs
require "base64"
require "forwardable"
require "net/http"
require "net/https"
require "openssl"
require "rexml/document"
require "time"

# proxy stuff
require "sqs/roxy/moxie"
require "sqs/roxy/proxy"

# sqs stuff
require "sqs/connection"
require "sqs/exceptions"
require "sqs/message"
require "sqs/parser"
require "sqs/queue"
require "sqs/service"
require "sqs/signature"

module Sqs
  # Default (and only) host serving SQS stuff
  HOST = "queue.amazonaws.com"
end
