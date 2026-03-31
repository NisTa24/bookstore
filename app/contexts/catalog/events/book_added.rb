module Catalog
  module Events
    BookAdded = Data.define(:book_id, :title, :isbn, :author_id, :category_id)
  end
end
