require 'dockmaster/parser/doc_parser'

module Dockmaster
  # This parser class parses single-line modifiers, such as module_function and private
  class SingleLineModParser
    class << self
      def parse(_line, ast, _comments, store, _static, _priv)
        return nil unless ast.type == :send
        if ast.to_a[1] == :module_function
          DocParser.make_static
        elsif ast.to_a[1] == :private
          DocParser.make_private
        end
        store
      end
    end
  end
end
