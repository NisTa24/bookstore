module Catalog
  module Commands
    class UpdateBook < Shared::BaseCommand
      def call(book_id:, **attributes)
        book = Catalog::Book.find(book_id)

        if attributes[:isbn]
          isbn_vo = Catalog::ValueObjects::ISBN.new(value: attributes[:isbn])
          attributes[:isbn] = isbn_vo.to_s
        end

        book.update!(attributes)

        event = Catalog::Events::BookUpdated.new(
          book_id: book.id,
          title: book.title,
          isbn: book.isbn,
          changes: attributes.keys.map(&:to_s)
        )

        log_event(:book_updated, event)
        broadcast(:book_updated, event)
      rescue ActiveRecord::RecordNotFound
        broadcast(:update_book_failed, errors: ["Book not found: #{book_id}"])
      rescue ActiveRecord::RecordInvalid => e
        broadcast(:update_book_failed, errors: e.record.errors.full_messages)
      rescue ArgumentError => e
        broadcast(:update_book_failed, errors: [e.message])
      end
    end
  end
end
