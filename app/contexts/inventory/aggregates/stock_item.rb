module Inventory
  class StockItem < ActiveRecord::Base
    self.table_name = "inventory_stock_items"

    before_create :set_uuid
    validates :book_id, presence: true, uniqueness: true
    validates :quantity_on_hand, numericality: { greater_than_or_equal_to: 0 }
    validates :quantity_reserved, numericality: { greater_than_or_equal_to: 0 }

    def available_quantity
      quantity_on_hand - quantity_reserved
    end

    def can_reserve?(quantity)
      available_quantity >= quantity
    end

    def reserve!(quantity)
      with_lock do
        reload
        raise InsufficientStockError unless can_reserve?(quantity)
        update!(quantity_reserved: quantity_reserved + quantity)
      end
    end

    def release!(quantity)
      with_lock do
        reload
        new_reserved = [quantity_reserved - quantity, 0].max
        update!(quantity_reserved: new_reserved)
      end
    end

    def deduct!(quantity)
      with_lock do
        reload
        update!(
          quantity_on_hand: quantity_on_hand - quantity,
          quantity_reserved: quantity_reserved - quantity
        )
      end
    end

    private

    def set_uuid
      self.id ||= SecureRandom.uuid
    end
  end

  class InsufficientStockError < StandardError
    def message
      "Insufficient stock available"
    end
  end
end
