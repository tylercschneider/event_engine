module EventEngine
  class HandlerRegistry
    def initialize
      @handlers = []
    end

    def register(handler, levels:)
      @handlers << handler
    end

    def dispatch(event)
      @handlers.each { |handler| handler.call(event) }
    end
  end
end
