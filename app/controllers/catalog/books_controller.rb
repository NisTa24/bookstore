module Catalog
  class BooksController < ApplicationController
    def index
      @books = Catalog::ReadModels::BookListing.all
    end

    def show
      @book = Catalog::ReadModels::BookListing.find_by(book_id: params[:id])
    end

    def new
      @authors = Catalog::Author.all
      @categories = Catalog::Category.all
    end

    def create
      @authors = Catalog::Author.all
      @categories = Catalog::Category.all

      command = Catalog::Commands::AddBook.new

      command.on(:book_added) do |event|
        redirect_to catalog_book_path(event.book_id), notice: "Book was successfully created."
      end

      command.on(:add_book_failed) do |errors:|
        flash.now[:alert] = errors.join(", ")
        render :new, status: :unprocessable_entity
      end

      command.call(
        title: book_params[:title],
        isbn: book_params[:isbn],
        description: book_params[:description],
        author_id: book_params[:author_id].presence,
        category_id: book_params[:category_id].presence
      )
    end

    private

    def book_params
      params.require(:book).permit(:title, :isbn, :description, :author_id, :category_id)
    end
  end
end
