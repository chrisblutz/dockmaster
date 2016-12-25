require 'unparser'

module Dockmaster
  # Represents an ERB binding
  # for the templates
  class ERBBinding
    autoload :CGI, 'cgi'

    attr_reader :master_store, :store, :base_helper, :theme_helper

    def initialize(master_store, store, base_helper, theme_helper, renderer)
      @master_store = master_store
      @store = store

      @base_helper = base_helper
      @theme_helper = theme_helper

      @renderer = renderer
    end

    def erb_binding
      binding
    end

    def render
      return '' if @renderer.nil?
      @renderer.result(erb_binding)
    end

    def plugins
      Dockmaster::Plugin.plugins_by_id
    end

    def include(file, base_dir = Dir.pwd)
      full_file = File.join(base_dir, file)
      file = File.open(full_file)
      contents = file.read
      file.close
      contents
    end

    def link_to(rb_string)
      see_link = Dockmaster::DocProcessor.see_links[rb_string]
      see_link
    end

    def escape_html(str)
      CGI.escapeHTML(str)
    end
  end
end
