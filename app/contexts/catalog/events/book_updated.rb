module Catalog
  module Events
    BookUpdated = Data.define(:book_id, :title, :isbn, :changes)
  end
end
