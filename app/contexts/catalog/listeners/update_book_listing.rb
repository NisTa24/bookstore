module Catalog
  module Listeners
    class UpdateBookListing < Shared::BaseListener
      def book_added(event)
        log_received(:book_added, event)

        author = Catalog::Author.find_by(id: event.author_id)
        category = Catalog::Category.find_by(id: event.category_id)

        Catalog::ReadModels::BookListing.create!(
          book_id: event.book_id,
          title: event.title,
          isbn: event.isbn,
          author_name: author&.name,
          category_name: category&.name,
          status: "active"
        )
      end

      def book_updated(event)
        log_received(:book_updated, event)

        listing = Catalog::ReadModels::BookListing.find_by(book_id: event.book_id)
        return unless listing

        listing.update!(title: event.title, isbn: event.isbn)
      end

      def book_retired(event)
        log_received(:book_retired, event)

        listing = Catalog::ReadModels::BookListing.find_by(book_id: event.book_id)
        listing&.update!(status: "retired")
      end
    end
  end
end
