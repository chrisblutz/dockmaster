module Dockmaster
  # This loader class loads files that have the {@code .html} file extension
  class HTMLLoader
    class << self
      def extensions
        ['.html']
      end

      def load_file(file)
        IO.read(file)
      end
    end
  end
end
