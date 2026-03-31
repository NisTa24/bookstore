module Api
  module V1
    class BooksController < BaseController
      # GET /api/v1/books
      def index
        listings = Catalog::ReadModels::BookListing.in_catalog.order(created_at: :desc)
        render json: listings
      end

      # GET /api/v1/books/:id
      def show
        listing = Catalog::ReadModels::BookListing.find_by!(book_id: params[:id])
        render json: listing
      rescue ActiveRecord::RecordNotFound
        render_error("Book not found", status: :not_found)
      end

      # POST /api/v1/books
      def create
        command = Catalog::Commands::AddBook.new

        command
          .on(:book_added) do |event|
            render json: {
              book_id: event.book_id,
              title: event.title,
              isbn: event.isbn,
              message: "Book added to catalog"
            }, status: :created
          end
          .on(:add_book_failed) { |errors:| render_error(errors) }

        command.call(**book_params)
      end

      # PATCH /api/v1/books/:id
      def update
        command = Catalog::Commands::UpdateBook.new

        command
          .on(:book_updated) do |event|
            render json: { book_id: event.book_id, title: event.title, message: "Book updated" }
          end
          .on(:update_book_failed) { |errors:| render_error(errors) }

        command.call(book_id: params[:id], **update_params)
      end

      # DELETE /api/v1/books/:id
      def destroy
        command = Catalog::Commands::RetireBook.new

        command
          .on(:book_retired) { |event| render json: { book_id: event.book_id, message: "Book retired" } }
          .on(:retire_book_failed) { |errors:| render_error(errors) }

        command.call(book_id: params[:id])
      end

      private

      def book_params
        params.require(:book).permit(:title, :isbn, :description, :author_id, :category_id).to_h.symbolize_keys
      end

      def update_params
        params.require(:book).permit(:title, :isbn, :description).to_h.symbolize_keys
      end
    end
  end
end
