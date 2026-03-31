module Catalog
  class Book < ActiveRecord::Base
    self.table_name = "catalog_books"

    belongs_to :author, class_name: "Catalog::Author", optional: true
    belongs_to :category, class_name: "Catalog::Category", optional: true

    before_create :set_uuid
    validates :title, presence: true
    validates :isbn, presence: true, uniqueness: true
    validates :status, inclusion: { in: %w[active retired] }

    scope :active, -> { where(status: "active") }

    def retire!
      update!(status: "retired")
    end

    def active?
      status == "active"
    end

    private

    def set_uuid
      self.id ||= SecureRandom.uuid
    end
  end
end
