require 'dockmaster/parser/doc_parser'

module Dockmaster
  # This parser class parses private statements
  class PrivateParser
    class << self
      def parse(_line, ast, _comments, store, _static, _priv)
        return nil unless ast.type == :send
        return nil unless ast.to_a[1] == :private
        DocParser.make_private
        store
      end
    end
  end
end
