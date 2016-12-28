require 'dockmaster/parser/doc_parser'

module Dockmaster
  # This parser class parses class and module declarations
  class ClassModuleParser
    class << self
      def parse(line, ast, comments, store, _static, _priv)
        return nil unless ast.type == :module || ast.type == :class
        type = ast.type
        return store if (child = DocParser.valid_first_child(ast, :const)).nil?
        in_cache = Dockmaster::Store.in_cache?(store, type, child.to_a[1])

        sub_store = Dockmaster::Store.from_cache(store, type, child.to_a[1])
        sub_store.doc_str = DocParser.closest_comment(line, comments)
        sub_store = DocParser.traverse_ast(ast, comments, sub_store, false, false)

        store.children << sub_store unless in_cache
        store
      end
    end
  end
end
