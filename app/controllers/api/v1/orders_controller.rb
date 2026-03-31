module Api
  module V1
    class OrdersController < BaseController
      # GET /api/v1/orders
      def index
        summaries = Ordering::ReadModels::OrderSummary.recent
        render json: summaries
      end

      # GET /api/v1/orders/:id
      def show
        summary = Ordering::ReadModels::OrderSummary.find_by!(order_id: params[:id])
        render json: summary
      rescue ActiveRecord::RecordNotFound
        render_error("Order not found", status: :not_found)
      end

      # POST /api/v1/orders
      def create
        command = Ordering::Commands::PlaceOrder.new

        command
          .on(:order_placed) do |event|
            render json: {
              order_id: event.order_id,
              order_number: event.order_number,
              total: format("%.2f", event.total_amount_cents / 100.0),
              currency: event.currency,
              status: "pending",
              message: "Order placed successfully"
            }, status: :created
          end
          .on(:place_order_failed) { |errors:| render_error(errors) }

        command.call(
          customer_email: order_params[:customer_email],
          items: order_params[:items].map { |i| i.to_h.symbolize_keys }
        )
      end

      # DELETE /api/v1/orders/:id
      def destroy
        command = Ordering::Commands::CancelOrder.new

        command
          .on(:order_cancelled) do |event|
            render json: {
              order_number: event.order_number,
              status: "cancelled",
              reason: event.reason
            }
          end
          .on(:cancel_order_failed) { |errors:| render_error(errors) }

        command.call(order_id: params[:id])
      end

      private

      def order_params
        params.require(:order).permit(:customer_email, items: [:book_id, :quantity])
      end
    end
  end
end
