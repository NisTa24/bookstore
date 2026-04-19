require "rails_helper"

RSpec.describe "Api::V1::Events", type: :request do
  describe "GET /api/v1/events" do
    before do
      3.times do |i|
        Shared::DomainEventLog.create(
          id: SecureRandom.uuid,
          event_type: "test_event_#{i}",
          payload: { index: i },
          source_command: "TestCommand",
          occurred_at: i.hours.ago
        )
      end
    end

    it "returns recent domain events" do
      get "/api/v1/events"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
    end

    it "returns events in reverse chronological order" do
      get "/api/v1/events"
      json = JSON.parse(response.body)

      event_types = json.map { |e| e["event_type"] }
      expect(event_types.first).to eq("test_event_0")
      expect(event_types.last).to eq("test_event_2")
    end

    it "limits to 50 events" do
      55.times do |i|
        Shared::DomainEventLog.create(
          id: SecureRandom.uuid,
          event_type: "bulk_#{i}",
          payload: {},
          source_command: "Bulk",
          occurred_at: (i + 10).minutes.ago
        )
      end

      get "/api/v1/events"
      json = JSON.parse(response.body)
      expect(json.size).to eq(50)
    end
  end
end
