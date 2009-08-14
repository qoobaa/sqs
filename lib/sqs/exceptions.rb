module Sqs
  module Error

    # All responses with a code between 300 and 599 that contain an
    # <Error></Error> body are wrapped in an ErrorResponse which
    # contains an Error object. This Error class generates a custom
    # exception with the name of the xml Error and its message. All
    # such runtime generated exception classes descend from
    # ResponseError and contain the ErrorResponse object so that all
    # code that makes a request can rescue ResponseError and get
    # access to the ErrorResponse.
    class ResponseError < StandardError
      attr_reader :response

      # ==== Parameters:
      # +message+:: what went wrong
      # +response+:: Net::HTTPResponse object or nil
      def initialize(message, response)
        @response = response
        super(message)
      end

      # Factory for all other Exception classes in module, each for every
      # error response available from AmazonAWS
      #
      # ==== Parameters:
      # +code+:: code name of exception
      #
      # ==== Returns:
      # Descendant of ResponseError suitable for that exception code or ResponseError class
      # if no class found
      def self.exception(code)
        Sqs::Error.const_get(code)
      rescue NameError
        ResponseError
      end
    end

    #:stopdoc:

    class AccessDenied < ResponseError; end
    class AuthFailure < ResponseError; end
    class ConflictingQueryParameter < ResponseError; end
    class ElementNotSigned < ResponseError; end
    class InternalError < ResponseError; end
    class InvalidAccessKeyId < ResponseError; end
    class InvalidAction < ResponseError; end
    class InvalidAddress < ResponseError; end
    class InvalidAttributeName < ResponseError; end
    class InvalidHttpRequest < ResponseError; end
    class InvalidMessageContents < ResponseError; end
    class InvalidParameterCombination < ResponseError; end
    class InvalidParameterValue < ResponseError; end
    class InvalidQueryParameter < ResponseError; end
    class InvalidRequest < ResponseError; end
    class InvalidSecurity < ResponseError; end
    class InvalidSecurityToken < ResponseError; end
    class MalformedSOAPSignature < ResponseError; end
    class MalformedVersion < ResponseError; end
    class MessageTooLong < ResponseError; end
    class MissingClientTokenId < ResponseError; end
    class MissingCredentials < ResponseError; end
    class MissingParameter < ResponseError; end
    class NoSuchVersion < ResponseError; end
    class NonExistentQueue < ResponseError; end
    class NotAuthorizedToUseVersion < ResponseError; end
    class QueueDeletedRecently < ResponseError; end
    class QueueNameExists < ResponseError; end
    class ReadCountOutOfRange < ResponseError; end
    class RequestExpired < ResponseError; end
    class RequestThrottled < ResponseError; end
    class SOAP11IncorrectDateFormat < ResponseError; end
    class SOAP11MissingAction < ResponseError; end
    class ServiceUnavailable < ResponseError; end
    class SignatureDoesNotMatch < ResponseError; end
    class SoapBodyMissing < ResponseError; end
    class SoapEnvelopeMissing < ResponseError; end
    class SoapEnvelopeParseError < ResponseError; end
    class UnknownEnvelopeNamespace < ResponseError; end
    class WSSecurityCorruptSignedInfo < ResponseError; end
    class WSSecurityCreatedDateIncorrectFormat < ResponseError; end
    class WSSecurityEncodingTypeError < ResponseError; end
    class WSSecurityExpiresDateIncorrectFormat < ResponseError; end
    class WSSecurityIncorrectValuetype < ResponseError; end
    class WSSecurityMissingValuetype < ResponseError; end
    class WSSecurityMultipleCredentialError < ResponseError; end
    class WSSecurityMultipleX509Error < ResponseError; end
    class WSSecuritySignatureError < ResponseError; end
    class WSSecuritySignatureMissing < ResponseError; end
    class WSSecuritySignedInfoMissing < ResponseError; end
    class WSSecurityTimestampExpired < ResponseError; end
    class WSSecurityTimestampExpiresMissing < ResponseError; end
    class WSSecurityTimestampMissing < ResponseError; end
    class WSSecurityX509CertCredentialError < ResponseError; end
    class X509ParseError < ResponseError; end
  end
end
