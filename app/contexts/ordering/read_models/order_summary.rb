module Ordering
  module ReadModels
    class OrderSummary < ActiveRecord::Base
      self.table_name = "ordering_order_summaries"

      before_create :set_uuid

      scope :by_status, ->(status) { where(status: status) }
      scope :recent, -> { order(created_at: :desc) }

      private

      def set_uuid
        self.id ||= SecureRandom.uuid
      end
    end
  end
end
