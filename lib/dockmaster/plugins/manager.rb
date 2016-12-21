module Dockmaster
  # This class represents a plugin manager, which handles event registries, etc.
  class Manager
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def event_handlers
      @event_handlers ||= {}
    end

    def register_handler(event, handler_class)
      event_handlers[event] = handler_class
    end

    def [](event)
      event_handlers[event]
    end
  end
end
