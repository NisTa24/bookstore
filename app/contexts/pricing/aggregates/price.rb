module Pricing
  class Price < ActiveRecord::Base
    self.table_name = "pricing_prices"

    before_create :set_uuid
    validates :book_id, presence: true
    validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :currency, presence: true
    validates :effective_from, presence: true

    scope :current_for_book, ->(book_id) {
      where(book_id: book_id)
        .where("effective_from <= ?", Time.current)
        .where("effective_until IS NULL OR effective_until > ?", Time.current)
        .order(effective_from: :desc)
        .limit(1)
    }

    def to_money
      Pricing::ValueObjects::Money.new(amount_cents: amount_cents, currency: currency)
    end

    private

    def set_uuid
      self.id ||= SecureRandom.uuid
    end
  end
end
