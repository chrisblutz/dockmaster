require 'dockmaster/parser/doc_parser'

module Dockmaster
  # This parser class parses method declarations
  class MethodParser
    class << self
      def parse(line, ast, comments, store, static, priv)
        return nil unless (ast.type == :defs && ast.to_a[0].type == :self) || ast.type == :def
        return store if priv && !Dockmaster.include_private?
        ast_ary = ast.to_a
        if ast.type == :def
          name = ast_ary[0]
          args_ast = ast_ary[1]
        elsif ast.type == :defs
          name = ast_ary[1]
          args_ast = ast_ary[2]
        end
        args = []

        unless args_ast.nil?
          if args_ast.type == :args
            args_ary = args_ast.to_a
            args_ary.each do |arg|
              args << arg.to_a[0] if arg.type == :arg
            end
          end
        end

        static = true if ast.type == :defs

        doc_str = DocParser.closest_comment(line, comments)
        data_store = if static
                       store.data_type(:static_method)
                     else
                       store.data_type(:instance_method)
                     end
        data_store.store(name, Dockmaster::Data.new(doc_str, DocParser.file, ast, line, priv))

        store
      end
    end
  end
end
