require 'erb'

# this does something
module Dockmaster
  class Output
    class << self
      def start_processing(storage)
        load_from_files

        docs_dir = File.join(Dir.pwd, 'doc/')
        Dir.mkdir(docs_dir) unless File.exist?(docs_dir)

        process(storage)
      end

      def process(storage)
        if storage.type == :none
          output = @index_renderer.result(storage.erb_binding)
          write_to_file(File.join(Dir.pwd, 'doc/index.html'), output)
        elsif storage.type == :module
          output = @module_renderer.result(storage.erb_binding)
          write_to_file(File.join(Dir.pwd, "doc/#{storage.path}.html"), output)
          mod_dir = File.join(Dir.pwd, "doc/#{storage.path}")
          Dir.mkdir(mod_dir) unless storage.children.empty? || File.exist?(mod_dir)
        elsif storage.type == :class
          output = @class_renderer.result(storage.erb_binding)
          write_to_file(File.join(Dir.pwd, "doc/#{storage.path}.html"), output)
        end
        storage.children.each do |child|
          process(child)
        end
      end

      def load_from_files
        @index_renderer ||= ERB.new(File.read(File.join(Dir.pwd, 'theme/index.html.erb')))
        @module_renderer ||= ERB.new(File.read(File.join(Dir.pwd, 'theme/module.html.erb')))
        @class_renderer ||= ERB.new(File.read(File.join(Dir.pwd, 'theme/class.html.erb')))
      end

      private

      def write_to_file(filename, output)
        File.open(filename, 'w') { |f| f.write(output) }
      end
    end
  end
end
