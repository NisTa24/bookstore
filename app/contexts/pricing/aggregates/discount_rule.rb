module Pricing
  class DiscountRule < ActiveRecord::Base
    self.table_name = "pricing_discount_rules"

    before_create :set_uuid
    validates :name, presence: true
    validates :discount_type, inclusion: { in: %w[percentage fixed_amount] }
    validates :value, presence: true, numericality: { greater_than: 0 }
    validates :valid_from, presence: true

    scope :active, -> { where(active: true) }
    scope :applicable_to, ->(book_id, category_id) {
      active
        .where("valid_from <= ?", Time.current)
        .where("valid_until IS NULL OR valid_until > ?", Time.current)
        .where("book_id = ? OR book_id IS NULL", book_id)
        .where("category_id = ? OR category_id IS NULL", category_id)
    }

    private

    def set_uuid
      self.id ||= SecureRandom.uuid
    end
  end
end
