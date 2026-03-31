module Api
  module V1
    class BaseController < ActionController::API
      private

      def render_error(errors, status: :unprocessable_entity)
        render json: { errors: Array(errors) }, status: status
      end
    end
  end
end
