module Dockmaster
  # This class represents processed documentation
  class Docs
    attr_reader :description, :fields

    def initialize(desc, fields)
      @description = desc
      @fields = fields
    end

    def [](field)
      @fields[field]
    end
  end
end
