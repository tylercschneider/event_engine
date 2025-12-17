module EventEngine
  class EventEmitter
    def self.emit(definition:)
      attributes = definition.to_outbox_attributes

      unless attributes.is_a?(Hash)
        raise ArgumentError, "to_outbox_attributes must return a Hash"
      end

      OutboxEvent.create!(attributes)
    end
  end
end
