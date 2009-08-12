module Sqs
  module Support
    def self.classify(symbol)
      camelize(symbol.to_s.sub(/.*\./, ''))
    end

    def self.camelize(lower_case_and_underscored_word)
      lower_case_and_underscored_word.to_s.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end
