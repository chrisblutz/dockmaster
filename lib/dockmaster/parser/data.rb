module Dockmaster
  # Represents data for a
  # method or field in a Store
  class Data
    attr_accessor :docs
    attr_reader :doc_str
    attr_reader :file
    attr_reader :ast
    attr_reader :line
    attr_reader :private
    attr_writer :readonly

    def initialize(doc_str, file, ast, line, priv)
      @doc_str = doc_str
      @file = file
      @ast = ast
      @line = line
      @private = priv
    end

    def readonly?
      @readonly ||= false
    end
  end
end
