module Shared
  class BaseCommand
    include Wisper::Publisher

    def self.call(...)
      new.call(...)
    end

    def call(*)
      raise NotImplementedError, "#{self.class}#call must be implemented"
    end

    private

    def log_event(event_type, payload)
      Shared::DomainEventLog.create!(
        id: SecureRandom.uuid,
        event_type: event_type.to_s,
        payload: payload.respond_to?(:to_h) ? payload.to_h : payload,
        source_command: self.class.name,
        occurred_at: Time.current
      )
    end
  end
end
