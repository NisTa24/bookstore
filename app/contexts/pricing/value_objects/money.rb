module Pricing
  module ValueObjects
    Money = Data.define(:amount_cents, :currency) do
      def initialize(amount_cents:, currency: "USD")
        raise ArgumentError, "amount_cents must be non-negative" if amount_cents.negative?
        super(amount_cents: amount_cents.to_i, currency: currency.to_s.upcase)
      end

      def to_f
        amount_cents / 100.0
      end

      def +(other)
        raise ArgumentError, "Currency mismatch" unless currency == other.currency
        self.class.new(amount_cents: amount_cents + other.amount_cents, currency: currency)
      end

      def *(multiplier)
        self.class.new(amount_cents: (amount_cents * multiplier).round, currency: currency)
      end

      def apply_percentage_discount(percentage)
        discount = (amount_cents * percentage / 100.0).round
        self.class.new(amount_cents: amount_cents - discount, currency: currency)
      end

      def to_s
        format("%.2f %s", to_f, currency)
      end
    end
  end
end
