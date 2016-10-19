module Dockmaster
  # Represents the binding to be passed
  # to ERB templates
  class ERBBinding
    attr_reader :master_store
    attr_reader :store
    attr_reader :helper

    def initialize(master_store, store)
      @master_store = master_store
      @store = store
    end
  end
end
