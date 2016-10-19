require 'erb'
require 'fileutils'

require 'dockmaster/output/erb/site_binding'
require 'dockmaster/output/erb/store_binding'

require 'dockmaster/theme'

module Dockmaster
  # Helps output the documentation
  # from the theme templates to valid
  # HTML files
  class Output
    class << self
      def start_processing(store)
        theme_home = Dockmaster::Theme.gem_source

        load_from_files(theme_home)

        docs_dir = File.join(Dir.pwd, Dockmaster::CONFIG.output)
        FileUtils.mkdir_p(docs_dir) unless File.exist?(docs_dir)

        move_includes

        process(store, store)
      end

      def process(master_store, store)
        renderer = nil
        if store.type == :none
          renderer = @index_renderer
        elsif store.type == :module
          renderer = @module_renderer
        elsif store.type == :class
          renderer = @class_renderer
        end
        return if renderer.nil?
        perform_write(renderer, master_store, store)
        store.children.each do |child|
          process(master_store, child)
        end
      end

      def load_from_files(theme_home)
        @site_renderer ||= ERB.new(File.read(File.join(theme_home, 'theme/site.html.erb')).rstrip!)
        @index_renderer ||= ERB.new(File.read(File.join(theme_home, 'theme/index.html.erb')).rstrip!)
        @module_renderer ||= ERB.new(File.read(File.join(theme_home, 'theme/module.html.erb')).rstrip!)
        @class_renderer ||= ERB.new(File.read(File.join(theme_home, 'theme/class.html.erb')).rstrip!)
      end

      def move_includes
        FileUtils.cp_r(File.join(Dir.pwd, 'theme/html/include/.'), File.join(Dir.pwd, 'doc/'))
      end

      private

      def form_output(renderer, master_store, store)
        if Dockmaster.debug?
          if store.type == :none
            puts 'Rendering index page...'
          else
            puts "Rendering #{store.type} page for #{store.rb_string}..."
          end
        end
        @site_renderer.result(site_binding(master_store, store, renderer)) { renderer.result(store.erb_binding) }
      end

      def site_binding(master_store, store, renderer)
        binding = SiteBinding.new(master_store, store, renderer)
        binding.erb_binding
      end

      def perform_write(renderer, master_store, store)
        output = form_output(renderer, master_store, store)
        name = 'index' if store.type == :none
        path = "#{Dockmaster::CONFIG.output}/#{name || store.path}.html"
        write_file(File.join(Dir.pwd, path), output)
      end

      def write_file(filename, output)
        Dir.mkdir(File.dirname(filename)) unless File.exist?(File.dirname(filename))
        File.open(filename, 'w') { |f| f.write(output) }
      end
    end
  end
end
