module Api
  module V1
    class InventoryController < BaseController
      # GET /api/v1/inventory/:book_id
      def show
        stock = Inventory::StockItem.find_by!(book_id: params[:book_id])
        render json: {
          book_id: stock.book_id,
          on_hand: stock.quantity_on_hand,
          reserved: stock.quantity_reserved,
          available: stock.available_quantity
        }
      rescue ActiveRecord::RecordNotFound
        render_error("Stock record not found", status: :not_found)
      end

      # POST /api/v1/inventory
      def create
        command = Inventory::Commands::RegisterStock.new

        command
          .on(:stock_registered) do |event|
            render json: {
              book_id: event.book_id,
              quantity_added: event.quantity_added,
              new_total: event.new_total,
              message: "Stock registered"
            }, status: :created
          end
          .on(:register_stock_failed) { |errors:| render_error(errors) }

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
end
