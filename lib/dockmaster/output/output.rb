require 'erb'
require 'fileutils'
require 'stringio'

require 'dockmaster/output/erb/site_binding'
require 'dockmaster/output/erb/store_binding'

# this does something
module Dockmaster
  class Output
    class << self
      def start_processing(store)
        load_from_files

        docs_dir = File.join(Dir.pwd, Dockmaster::CONFIG.output_dir)
        Dir.mkdir(docs_dir) unless File.exist?(docs_dir)

        move_includes

        process(store, store)
      end

      def process(master_store, store)
        if store.type == :none
          output = form_output(@index_renderer, master_store, store)
          write_to_file(File.join(Dir.pwd, "#{Dockmaster::CONFIG.output_dir}/index.html"), output)
        elsif store.type == :module
          output = form_output(@module_renderer, master_store, store)
          write_to_file(File.join(Dir.pwd, "#{Dockmaster::CONFIG.output_dir}/#{store.path}.html"), output)
          mod_dir = File.join(Dir.pwd, "#{Dockmaster::CONFIG.output_dir}/#{store.path}")
          Dir.mkdir(mod_dir) unless store.children.empty? || File.exist?(mod_dir)
        elsif store.type == :class
          output = form_output(@class_renderer, master_store, store)
          write_to_file(File.join(Dir.pwd, "#{Dockmaster::CONFIG.output_dir}/#{store.path}.html"), output)
        end
        store.children.each do |child|
          process(master_store, child)
        end
      end

      def load_from_files
        @site_renderer ||= ERB.new(File.read(File.join(Dir.pwd, 'theme/html/site.html.erb')).rstrip!)
        @index_renderer ||= ERB.new(File.read(File.join(Dir.pwd, 'theme/html/index.html.erb')).rstrip!)
        @module_renderer ||= ERB.new(File.read(File.join(Dir.pwd, 'theme/html/module.html.erb')).rstrip!)
        @class_renderer ||= ERB.new(File.read(File.join(Dir.pwd, 'theme/html/class.html.erb')).rstrip!)
      end

      def move_includes
        FileUtils.cp_r(File.join(Dir.pwd, 'theme/html/include/.'), File.join(Dir.pwd, 'doc/'))
      end

      private

      def form_output(renderer, master_store, store)
        @site_renderer.result(site_binding(master_store, store, renderer)) { renderer.result(store.erb_binding) }
      end

      def site_binding(master_store, store, renderer)
        binding = SiteBinding.new(master_store, store, renderer)
        binding.erb_binding
      end

      def write_to_file(filename, output)
        File.open(filename, 'w') { |f| f.write(output) }
      end
    end
  end
end