require 'erb'
require 'fileutils'

require 'dockmaster/output/erb/base_helper'
require 'dockmaster/output/erb/erb_binding'

module Dockmaster
  # Helps output the documentation
  # from the theme templates to valid
  # HTML files
  class Output
    def initialize(base_template)
      filename = File.join(Dockmaster::Theme.gem_source, base_template)
      @base = ERB.new(File.read(filename).rstrip!)
      @base.filename = filename
    end

    def load_erb(template_path)
      filename = File.join(Dockmaster::Theme.gem_source, template_path)
      @erb = ERB.new(File.read(filename).rstrip!)
      @erb.filename = filename
      self
    end

    def render(master_store, store = nil, use_base = true)
      return if @erb.nil?
      store = master_store if store.nil?
      if Dockmaster.debug?
        if store.type == :none
          puts 'Rendering index page...'
        else
          puts "Rendering #{store.type} page for #{store.rb_string}..."
        end
      end
      if use_base
        binding_obj = site_binding(master_store, store, @erb)
        @output_str = @base.result(binding_obj)
      else
        binding_obj = site_binding(master_store, store, nil)
        @output_str = @erb.result(binding_obj)
      end
      perform_write(store)
    end

    private

    def site_binding(master_store, store, renderer)
      base_helper = BaseHelper.new(master_store, store)
      theme_helper = Dockmaster::Theme::ThemeHelper.new(master_store, store)
      binding = ERBBinding.new(master_store, store, base_helper, theme_helper, renderer)
      binding.erb_binding
    end

    def perform_write(store)
      name = case store.type
             when :module
               Dockmaster::Theme.module_output(store)
             when :class
               Dockmaster::Theme.class_output(store)
             when :none
               Dockmaster::Theme.index_output(store)
             end
      path = "#{Output.docs_dir}/#{name}"
      puts path
      write_file(path, @output_str)
    end

    def write_file(filename, output)
      Dir.mkdir(File.dirname(filename)) unless File.exist?(File.dirname(filename))
      File.open(filename, 'w') { |f| f.write(output) }
    end

    class << self
      def start_processing(store)
        load_from_files

        FileUtils.mkdir_p(docs_dir) unless File.exist?(docs_dir)

        move_includes

        process(store, store)

        misc_output = Output.new(@base_template)

        return unless Dockmaster::Theme.respond_to?(:misc_generation)

        Dockmaster::Theme.misc_generation(store, misc_output)
      end

      def docs_dir
        @docs_dir ||= File.join(Dir.pwd, Dockmaster::CONFIG[:output, 'docs'].chomp('/').chomp('\\'))
        @docs_dir
      end

      private

      def process(master_store, store)
        renderer = nil
        if store.type == :none
          renderer = @index_output
        elsif store.type == :module
          renderer = @module_output
        elsif store.type == :class
          renderer = @class_output
        end
        renderer.render(master_store, store, true)
        return if renderer.nil?
        store.children.each do |child|
          process(master_store, child)
        end
      end

      def load_from_files
        @base_template = Dockmaster::Theme.base_template
        @index_output ||= Output.new(@base_template)
        @index_output.load_erb(Dockmaster::Theme.index_template)
        @module_output ||= Output.new(@base_template)
        @module_output.load_erb(Dockmaster::Theme.module_template)
        @class_output ||= Output.new(@base_template)
        @class_output.load_erb(Dockmaster::Theme.class_template)
      end

      def move_includes
        return unless Dockmaster::Theme.respond_to?(:includes_dir)
        include_dir = File.join(Dockmaster::Theme.gem_source, Dockmaster::Theme.includes_dir)
        return unless File.exist?(include_dir)
        FileUtils.cp_r(include_dir + '/.', @docs_dir)
      end
    end
  end
end
