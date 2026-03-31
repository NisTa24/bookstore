module Pricing
  module ValueObjects
    Percentage = Data.define(:value) do
      def initialize(value:)
        val = value.to_f
        raise ArgumentError, "Percentage must be between 0 and 100" unless val >= 0 && val <= 100
        super(value: val)
      end

      def to_f
        value
      end

      def to_s
        "#{value}%"
      end
    end
  end
end
