module Catalog
  class BooksController < ApplicationController
    def index
      @books = Catalog::ReadModels::BookListing.all
    end

    def show
      @book = Catalog::ReadModels::BookListing.find_by(book_id: params[:id])
    end
  end
end
