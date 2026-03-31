module Catalog
  module Commands
    class AddBook < Shared::BaseCommand
      def call(title:, isbn:, description: nil, author_id: nil, category_id: nil)
        isbn_vo = Catalog::ValueObjects::ISBN.new(value: isbn)

        if Catalog::Book.exists?(isbn: isbn_vo.to_s)
          broadcast(:add_book_failed, errors: ["ISBN already exists: #{isbn_vo}"])
          return
        end

        book = Catalog::Book.create!(
          title: title,
          isbn: isbn_vo.to_s,
          description: description,
          author_id: author_id,
          category_id: category_id,
          status: "active"
        )

        event = Catalog::Events::BookAdded.new(
          book_id: book.id,
          title: book.title,
          isbn: book.isbn,
          author_id: author_id,
          category_id: category_id
        )

        log_event(:book_added, event)
        broadcast(:book_added, event)
      rescue ActiveRecord::RecordInvalid => e
        broadcast(:add_book_failed, errors: e.record.errors.full_messages)
      rescue ArgumentError => e
        broadcast(:add_book_failed, errors: [e.message])
      end
    end
  end
end
