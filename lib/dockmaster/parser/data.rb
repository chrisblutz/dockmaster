module Dockmaster
  # Represents data for a
  # method or field in a Store
  class Data
    attr_accessor :docs
    attr_reader :doc_str
    attr_reader :file
    attr_reader :ast
    attr_reader :line

    def initialize(doc_str, file, ast, line)
      @doc_str = doc_str
      @file = file
      @ast = ast
      @line = line
    end
  end
end
