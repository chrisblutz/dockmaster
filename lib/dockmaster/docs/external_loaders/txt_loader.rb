require 'dockmaster/docs/doc_processor'

module Dockmaster
  # This loader class loads files that have the {@code .txt} file extension
  class TXTLoader
    class << self
      def extensions
        ['.txt']
      end

      def load_file(file)
        lines = IO.read(file).split("\n")
        lines = DocProcessor.process_internal_documentation(lines)
        DocProcessor.format_lines(lines)
      end
    end
  end
end
