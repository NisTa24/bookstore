module Ordering
  module ValueObjects
    Email = Data.define(:value) do
      EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

      def initialize(value:)
        normalized = value.to_s.strip.downcase
        raise ArgumentError, "Invalid email: #{value}" unless normalized.match?(EMAIL_REGEX)
        super(value: normalized)
      end

      def to_s
        value
      end
    end
  end
end
