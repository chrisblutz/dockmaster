require 'dockmaster/parser/doc_parser'

module Dockmaster
  # This parser class parses field declarations
  class FieldParser
    class << self
      def parse(line, ast, comments, store, static, priv)
        valid = false
        ary = Array.new(ast.to_a)
        if ary.length >= 1
          ary.shift
          valid = ary[0] == :attr_reader
          valid = ary[0] == :attr_writer unless valid
          valid = ary[0] == :attr_accessor unless valid
        end
        return nil unless ast.type == :send && valid
        return store if priv && !Dockmaster.include_private?

        define = ary.shift

        doc_str = DocParser.closest_comment(line, comments)

        data_store = if static
                       store.data_type(:static_field)
                     else
                       store.data_type(:instance_field)
                     end

        ary.each do |child|
          next unless child.type == :sym
          data = Dockmaster::Data.new(doc_str, DocParser.file, ast, line, priv)
          data.readonly = true if define == :attr_reader
          data_store.store(child.to_a[0], data)
        end

        store
      end
    end
  end
end
