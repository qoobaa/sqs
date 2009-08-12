require "time"
require "openssl"
require "net/http"
require "net/https"
require "base64"
require "forwardable"
require "digest/md5"

require "xmlsimple"

require "sqs/roxy/proxy"
require "sqs/roxy/moxie"

require "sqs/connection"
require "sqs/exceptions"
require "sqs/service"
require "sqs/signature"

module Sqs
  # Default (and only) host serving S3 stuff
  HOST = "queue.amazonaws.com"
end
