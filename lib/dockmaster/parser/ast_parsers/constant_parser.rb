require 'dockmaster/parser/doc_parser'

module Dockmaster
  # This parser class parses constant value declarations
  class ConstantParser
    class << self
      def parse(line, ast, comments, store, _static, priv)
        return nil unless ast.type == :casgn
        return store if priv && !Dockmaster.include_private?
        ast_ary = ast.to_a
        name = ast_ary[1]

        doc_str = DocParser.closest_comment(line, comments)

        data = Dockmaster::Data.new(doc_str, DocParser.file, ast, line, priv)
        store.data_type(:constant).store(name, data)

        store
      end
    end
  end
end
