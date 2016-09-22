module Dockmaster
  class Data
    attr_reader :docs
    attr_reader :file
    attr_reader :ast
    attr_reader :line
    attr_reader :instance
    attr_reader :private

    def initialize(docs, file, ast, line, instance, priv)
      @docs = docs
      @file = file
      @ast = ast
      @line = line
      @instance = instance
      @private = priv
    end
  end
end
