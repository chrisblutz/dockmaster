require 'dockmaster/parser/doc_parser'

module Dockmaster
  # This parser class parses module_function statements
  class ModFuncStaticParser
    class << self
      def parse(_line, ast, _comments, store, _static, _priv)
        return nil unless ast.type == :send
        return nil unless ast.to_a[1] == :module_function
        DocParser.make_static
        store
      end
    end
  end
end
