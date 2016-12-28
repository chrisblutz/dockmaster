require 'dockmaster/docs/doc_processor'

module Dockmaster
  # This loader class loads files that have the {@code .txt} file extension
  class TXTLoader
    class << self
      def extensions
        ['.txt']
      end

      def load_file(file)
        DocProcessor.process_internal_documentation(IO.read(file))
      end
    end
  end
end
