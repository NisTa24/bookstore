module Api
  module V1
    class EventsController < BaseController
      # GET /api/v1/events
      def index
        events = Shared::DomainEventLog.order(occurred_at: :desc).limit(50)
        render json: events
      end
    end
  end
end
