module Ordering
  class Order < ActiveRecord::Base
    self.table_name = "ordering_orders"

    has_many :order_lines, class_name: "Ordering::OrderLine",
             foreign_key: "order_id", dependent: :destroy

    before_create :set_uuid
    validates :order_number, presence: true, uniqueness: true
    validates :customer_email, presence: true
    validates :status, inclusion: { in: %w[pending confirmed fulfilled cancelled] }

    def confirm!
      update!(status: "confirmed")
    end

    def cancel!
      update!(status: "cancelled")
    end

    def pending?
      status == "pending"
    end

    def confirmed?
      status == "confirmed"
    end

    private

    def set_uuid
      self.id ||= SecureRandom.uuid
    end
  end
end
