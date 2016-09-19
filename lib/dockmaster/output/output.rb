require 'erb'

# this does something
module Dockmaster
  class Output
    class << self
      def start_processing(store)
        load_from_files

        docs_dir = File.join(Dir.pwd, 'doc/')
        Dir.mkdir(docs_dir) unless File.exist?(docs_dir)

        process(store)
      end

      def process(store)
        if store.type == :none
          output = @index_renderer.result(store.erb_binding)
          write_to_file(File.join(Dir.pwd, 'doc/index.html'), output)
        elsif store.type == :module
          output = @module_renderer.result(store.erb_binding)
          write_to_file(File.join(Dir.pwd, "doc/#{store.path}.html"), output)
          mod_dir = File.join(Dir.pwd, "doc/#{store.path}")
          Dir.mkdir(mod_dir) unless store.children.empty? || File.exist?(mod_dir)
        elsif store.type == :class
          output = @class_renderer.result(store.erb_binding)
          write_to_file(File.join(Dir.pwd, "doc/#{store.path}.html"), output)
        end
        store.children.each do |child|
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
