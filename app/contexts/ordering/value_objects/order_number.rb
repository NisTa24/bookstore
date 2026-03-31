module Ordering
  module ValueObjects
    OrderNumber = Data.define(:value) do
      def initialize(value: nil)
        generated = value || "ORD-#{SecureRandom.hex(6).upcase}"
        super(value: generated)
      end

      def to_s
        value
      end
    end
  end
end
