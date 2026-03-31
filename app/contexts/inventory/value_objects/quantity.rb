module Inventory
  module ValueObjects
    Quantity = Data.define(:value) do
      def initialize(value:)
        raise ArgumentError, "Quantity must be positive" unless value.to_i.positive?
        super(value: value.to_i)
      end

      def to_i
        value
      end

      def to_s
        value.to_s
      end
    end
  end
end
