require 'dockmaster/parser/doc_parser'

module Dockmaster
  # This parser class parses {@code class &lt;&lt; self} declarations
  class SClassStaticParser
    class << self
      def parse(_line, ast, comments, store, _static, _priv)
        return nil unless ast.type == :sclass
        return store if DocParser.valid_first_child(ast, :self).nil?
        store = DocParser.traverse_ast(ast, comments, store, true, false)
        store
      end
    end
  end
end
