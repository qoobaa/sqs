module Sqs
  module Support
    def self.assert_valid_keys(hash, *valid_keys)
      unknown_keys = hash.keys - Array(valid_keys).flatten
      raise ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}" unless unknown_keys.empty?
    end

    def self.classify(symbol)
      camelize(symbol.to_s.sub(/.*\./, ''))
    end

    def self.camelize(lower_case_and_underscored_word)
      lower_case_and_underscored_word.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end
