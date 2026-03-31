module Catalog
  module ValueObjects
    ISBN = Data.define(:value) do
      ISBN_13_REGEX = /\A\d{13}\z/
      ISBN_10_REGEX = /\A\d{9}[\dX]\z/

      def initialize(value:)
        normalized = value.to_s.gsub(/[-\s]/, "")
        unless normalized.match?(ISBN_13_REGEX) || normalized.match?(ISBN_10_REGEX)
          raise ArgumentError, "Invalid ISBN: #{value}"
        end
        super(value: normalized)
      end

      def to_s
        value
      end

      def isbn_13?
        value.length == 13
      end
    end
  end
end
