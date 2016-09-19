require 'erb'

#
module Dockmaster
  class DocParser
    class << self
      def begin
        files = find_all_source_files
        storage_ary = []
        files.each do |file|
          storage_ary << parse(file)
        end
        storage_ary
      end

      def find_all_source_files
        # TODO: Allow changing source folder
        home = File.join(Dir.pwd, '/lib')
        Dir["#{home}/**/*.rb"]
      end

      def parse(file)
        parser = Parser::CurrentRuby.new
        parser.diagnostics.all_errors_are_fatal = true
        parser.diagnostics.ignore_warnings = true
        buffer = Parser::Source::Buffer.new(file)
        buffer.source = File.read(file)
        result_ary = parser.parse_with_comments(buffer)
        ast = result_ary[0]
        comments = result_ary[1]
        comment_locs = parse_comment_locs(comments)
        @token_lines = []
        storage = traverse_ast(ast, comment_locs, Dockmaster::Storage.new(nil), false)

        storage
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

      def traverse_ast(ast, comments, storage, check_children_only = true)
        if check_children_only
          ast.children.each do |child|
            next unless child.class.to_s == 'Parser::AST::Node'
            storage = perform_parse(child, comments, storage)
          end
        else
          storage = perform_parse(ast, comments, storage)
        end

        storage
      end

      def perform_parse(ast, comments, storage)
        @token_lines << ast.loc.line
        @token_lines << ast.loc.last_line
        if ast.type == :module
          storage.children << define_module_in_ast(ast.loc.line, ast, comments, Dockmaster::Storage.new(storage))
        elsif ast.type == :class
          storage.children << define_class_in_ast(ast.loc.line, ast, comments, Dockmaster::Storage.new(storage))
        elsif ast.type == :def
          storage = define_method_in_ast(ast.loc.line, ast, comments, storage)
        else
          storage = traverse_ast(ast, comments, storage)
        end

        storage
      end

      def define_module_in_ast(line, ast, comments, storage)
        unless ast.children[0].nil?
          child = ast.children[0]
          if child.type == :const
            storage.type = :module
            storage.name = child.to_a[1]
            storage.docs = closest_comment(line, comments)
            storage = traverse_ast(ast, comments, storage)
          end
        end

        storage
      end

      def define_class_in_ast(line, ast, comments, storage)
        unless ast.children[0].nil?
          child = ast.children[0]
          if child.type == :const
            storage.type = :class
            storage.name = child.to_a[1]
            storage.docs = closest_comment(line, comments)
            # TODO: inheritance
            storage = traverse_ast(ast, comments, storage)
          end
        end

        storage
      end

      def define_method_in_ast(line, ast, comments, storage)
        ast_ary = ast.to_a
        name = ast_ary[0]
        args_ast = ast_ary[1]
        args = []

        unless args_ast.nil?
          if args_ast.type == :args
            args_ary = args_ast.to_a
            args_ary.each do |arg|
              args << arg.to_a[0] if arg.type == :arg
            end
          end
        end

        docs = closest_comment(line, comments)

        storage.methods.store(name, docs)

        storage
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

      def closest_comment(line, comments)
        l = closest_comment_line(line, comments)
        return '' if l == -1
        comments[l]
      end
    end
  end
end
