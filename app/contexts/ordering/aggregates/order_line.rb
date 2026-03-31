module Ordering
  class OrderLine < ActiveRecord::Base
    self.table_name = "ordering_order_lines"

    belongs_to :order, class_name: "Ordering::Order"

    before_create :set_uuid
    validates :book_id, presence: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

    def subtotal_cents
      quantity * unit_price_cents
    end

    private

    def set_uuid
      self.id ||= SecureRandom.uuid
    end
  end
end
