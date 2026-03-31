module Shared
  class DomainEventLog < ActiveRecord::Base
    self.table_name = "domain_events_log"
  end
end
