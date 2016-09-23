module Dockmaster
  # Represents data for a
  # method or field in a Store
  class Data
    attr_reader :docs
    attr_reader :file
    attr_reader :ast
    attr_reader :line

    def initialize(docs, file, ast, line)
      @docs = docs
      @file = file
      @ast = ast
      @line = line
    end
  end
end
