module Dockmaster
  # This class handles the API for abstract syntax tree parsing
  class ParserRegistry
    class << self
      def registered
        @registry ||= []
      end

      def register(parser)
        registered << parser
      end

      def parse(line, ast, comments, store, static, priv)
        registered.each do |parser|
          if parser.respond_to?(:parse)
            result = parser.parse(line, ast, comments, store, static, priv)
            return result unless result.nil?
          end
        end

        nil
      end

      def separators
        @separators ||= {}
      end

      def register_separator(type, separator)
        separators[type] = separator
      end
    end
  end
end
