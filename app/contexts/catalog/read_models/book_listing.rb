module Catalog
  module ReadModels
    class BookListing < ActiveRecord::Base
      self.table_name = "catalog_book_listings"

      before_create :set_uuid

      scope :available, -> { where(status: "active").where("stock_available > 0") }
      scope :in_catalog, -> { where(status: "active") }
      scope :by_category, ->(name) { where(category_name: name) }

      private

      def set_uuid
        self.id ||= SecureRandom.uuid
      end
    end
  end
end
