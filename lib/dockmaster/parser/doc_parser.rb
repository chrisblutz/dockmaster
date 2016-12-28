require 'stringio'

require 'dockmaster/parser/parser_registry'
require 'dockmaster/parser/ast_parsers/class_module_parser'
require 'dockmaster/parser/ast_parsers/constant_parser'
require 'dockmaster/parser/ast_parsers/field_parser'
require 'dockmaster/parser/ast_parsers/method_parser'
require 'dockmaster/parser/ast_parsers/sclass_static_parser'
require 'dockmaster/parser/ast_parsers/single_line_mod_parser'

module Dockmaster
  # Parses source code and
  # converts it into Store
  # instances for output
  class DocParser
    class << self
      attr_reader :file

      def begin
        register_default_parsers

        included = Dockmaster::Source.sort_source_files(Dockmaster::Source.find_all_source_files)

        store = Dockmaster::Store.new(nil, :none, '')
        included.each do |file|
          puts "Parsing #{file.sub(Dir.pwd, '')}..." if Dockmaster.debug?
          store = parse_file(file, store, false)
        end

        store.parse_see_links
        store.parse_docs

        store
      end

      def parse_file(file, store, clear_cache = true)
        @file = file

        Dockmaster::Store.clear_cache if clear_cache
        buffer = Parser::Source::Buffer.new(file)
        buffer.source = File.read(file)
        store = parse(buffer, store)

        store
      end

      def parse_string(string, store)
        @file = '<none>'

        Dockmaster::Store.clear_cache
        buffer = Parser::Source::Buffer.new('(string)')
        buffer.source = string
        store = parse(buffer, store)

        store
      end

      def parse(buffer, store)
        parser = Parser::CurrentRuby.new
        parser.diagnostics.all_errors_are_fatal = true
        parser.diagnostics.ignore_warnings = true
        result_ary = parser.parse_with_comments(buffer)
        ast = result_ary[0]
        comments = result_ary[1]
        comment_locs = parse_comment_locs(comments)
        @static = false
        @private = false
        @token_lines = []
        store = traverse_ast(ast, comment_locs, store, false, false, false)

        store
      end

      def traverse_ast(ast, comments, store, static, priv, check_children_only = true)
        use_static = false
        use_priv = false
        if check_children_only
          ast.children.each do |child|
            next unless child.class.to_s == 'Parser::AST::Node'
            use_static = true if @static
            @static = false
            should_be_static = if use_static
                                 true
                               else
                                 static
                               end
            use_priv = true if @private
            @private = false
            should_be_private = if use_priv
                                  true
                                else
                                  priv
                                end
            store = perform_parse(child, comments, store, should_be_static, should_be_private)
          end
        else
          store = perform_parse(ast, comments, store, static, priv)
        end
        store
      end

      def closest_comment(line, comments)
        l = closest_comment_line(line, comments)
        return '' if l == -1
        comments[l]
      end

      def valid_first_child(ast, type)
        unless ast.children[0].nil?
          child = ast.children[0]
          return child if child.type == type
        end
        nil
      end

      def make_private
        @private = true
      end

      def make_static
        @static = true
      end

      def register_default_parsers
        ParserRegistry.register(ClassModuleParser)
        ParserRegistry.register(ConstantParser)
        ParserRegistry.register(FieldParser)
        ParserRegistry.register(MethodParser)
        ParserRegistry.register(SClassStaticParser)
        ParserRegistry.register(SingleLineModParser)

        ParserRegistry.register_separator(:instance_method, '#')
        ParserRegistry.register_separator(:static_method, '.')
        ParserRegistry.register_separator(:instance_field, '#')
        ParserRegistry.register_separator(:static_field, '.')
        ParserRegistry.register_separator(:constant, '::')
      end

      private

      def parse_comment_locs(comments)
        comment_hash = {}

        prior = -1
        comment = ''

        comments.each do |c|
          line = c.loc.line

          if line == prior + 1
            prior = line
            comment += "\n#{c.text}"
          else
            comment_hash[prior] = comment unless comment.empty?
            prior = line
            comment = c.text
          end
        end

        comment_hash[prior] = comment unless comment.empty?

        comment_hash
      end

      def perform_parse(ast, comments, store, static, priv)
        return store if ast.nil? || ast.loc.nil? || ast.loc.expression.nil?
        @token_lines << ast.loc.line
        @token_lines << ast.loc.last_line
        result = ParserRegistry.parse(ast.loc.line, ast, comments, store, static, priv)
        store = if result.nil?
                  traverse_ast(ast, comments, store, static, priv)
                else
                  result
                end
        store
      end

      def closest_comment_line(line, comments)
        i = line - 1
        while i > 0
          return -1 if @token_lines.include?(i)
          return i if comments.key?(i)
          i -= 1
        end
        -1
      end
    end
  end
end
