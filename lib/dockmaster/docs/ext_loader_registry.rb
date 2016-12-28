module Dockmaster
  # This class handles the loading of files used in {@code @ext} annotations
  class ExtLoaderRegistry
    class << self
      def registered
        @registry ||= []
      end

      def register(loader)
        registered << loader
      end

      def load(file)
        extension = File.extname(file)
        registered.each do |loader|
          next unless loader.respond_to?(:extensions) && loader.respond_to?(:load_file)
          next unless loader.extensions.include?(extension)
          result = loader.load_file(file)
          return result.strip unless result.nil?
        end

        ''
      end
    end
  end
end
