module Catalog
  module Commands
    class RetireBook < Shared::BaseCommand
      def call(book_id:)
        book = Catalog::Book.find(book_id)
        book.retire!

        event = Catalog::Events::BookRetired.new(book_id: book.id)

        log_event(:book_retired, event)
        broadcast(:book_retired, event)
      rescue ActiveRecord::RecordNotFound
        broadcast(:retire_book_failed, errors: ["Book not found: #{book_id}"])
      end
    end
  end
end
