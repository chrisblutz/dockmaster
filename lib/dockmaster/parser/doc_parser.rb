
module Dockmaster
  class DocParser
    class << self
      def find_all_source_files
        # TODO: Allow changing source folder
        home = File.join(Dir.pwd, '/lib')
        Dir["#{home}/**/*.rb"]
      end

      # ary = Parser::CurrentRuby.parse_with_comments(File.open('dockmaster/configuration.rb', 'r').read)

      # def rec(ast, indent)
      #  ast.children.each do |child|
      #    if child.class.to_s == 'Parser::AST::Node'
      #      puts 'module-test' if child.type == :module
      #      puts indent + child.type.to_s
      #      # puts indent + child.to_s
      #      rec(child, indent + '  ')
      #    else
      #      puts indent + child.to_s
      #    end
      #  end
      # end
    end
  end
end
