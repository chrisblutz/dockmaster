module Dockmaster
  class Data
    attr_reader :file
    attr_reader :ast
    attr_reader :line

    def initialize(file, ast, line)
      @file = file
      @ast = ast
      @line = line
    end
  end
end
