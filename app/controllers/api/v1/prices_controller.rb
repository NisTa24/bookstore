module Api
  module V1
    class PricesController < BaseController
      # GET /api/v1/prices/:book_id
      def show
        price = Pricing::Price.current_for_book(params[:book_id]).first
        if price
          render json: {
            book_id: price.book_id,
            amount: format("%.2f", price.amount_cents / 100.0),
            currency: price.currency,
            effective_from: price.effective_from
          }
        else
          render_error("No current price found", status: :not_found)
        end
      end

      # POST /api/v1/prices
      def create
        command = Pricing::Commands::SetBookPrice.new

        command
          .on(:price_set) do |event|
            render json: {
              book_id: event.book_id,
              amount: format("%.2f", event.amount_cents / 100.0),
              currency: event.currency,
              message: "Price set"
            }, status: :created
          end
          .on(:set_book_price_failed) { |errors:| render_error(errors) }

        command.call(
          book_id: price_params[:book_id],
          amount_cents: price_params[:amount_cents].to_i,
          currency: price_params[:currency] || "USD"
        )
      end

      private

      def price_params
        params.require(:price).permit(:book_id, :amount_cents, :currency)
      end
    end
  end
end
