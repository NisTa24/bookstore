module Shared
  class BaseListener
    private

    def log_received(event_name, data)
      Rails.logger.info(
        "[#{self.class.name}] Received #{event_name}: #{data.inspect}"
      )
    end
  end
end
