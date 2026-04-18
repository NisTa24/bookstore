module Inventory
  class StockItemsController < ApplicationController
    def index
      @stock_items = Inventory::StockItem.all
      @books = Catalog::ReadModels::BookListing.all.index_by(&:book_id)
    end

    def show
      @stock = Inventory::StockItem.find_by!(book_id: params[:id])
      @book = Catalog::ReadModels::BookListing.find_by(book_id: params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to catalog_books_path, alert: "Stock record not found"
    end

    def new
      @books = Catalog::ReadModels::BookListing.all
    end

    def create
      @books = Catalog::ReadModels::BookListing.all

      command = Inventory::Commands::RegisterStock.new
      command.on(:stock_registered) do |event|
        redirect_to inventory_stock_item_path(event.book_id), notice: "Stock was successfully registered."
      end
      command.on(:register_stock_failed) do |errors:|
        flash.now[:alert] = errors.join(", ")
        render :new, status: :unprocessable_entity
      end

      command.call(
        book_id: stock_params[:book_id],
        quantity: stock_params[:quantity].to_i
      )
    end

    private

    def stock_params
      params.require(:stock).permit(:book_id, :quantity)
    end
  end
end
