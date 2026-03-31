module Catalog
  class Author < ActiveRecord::Base
    self.table_name = "catalog_authors"

    before_create :set_uuid
    validates :name, presence: true

    private

    def set_uuid
      self.id ||= SecureRandom.uuid
    end
  end
end
