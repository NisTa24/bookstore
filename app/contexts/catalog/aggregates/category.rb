module Catalog
  class Category < ActiveRecord::Base
    self.table_name = "catalog_categories"

    before_create :set_uuid
    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true

    private

    def set_uuid
      self.id ||= SecureRandom.uuid
    end
  end
end
