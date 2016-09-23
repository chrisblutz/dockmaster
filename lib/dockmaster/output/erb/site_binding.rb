require 'unparser'

module Dockmaster
  # Represents an ERB binding
  # for the site.html.erb template
  class SiteBinding
    def initialize(master_store, store, renderer)
      @master_store = master_store
      @store = store
      @renderer = renderer
    end

    attr_reader :store

    def render
      @renderer.result(@store.erb_binding)
    end

    def render_method(name)
      if @store.method_data.key?(name)
        data = @store.method_data[name]
        return render_data(data)
      end
      ''
    end

    def render_field(name)
      if @store.field_data.key?(name)
        data = @store.field_data[name]
        return render_data(data)
      end
      ''
    end

    def render_data(data)
      code = Unparser.unparse(data.ast)
      code = "# File '#{data.file.sub(Dir.pwd, '')}', line #{data.line}\n\n#{code}"
      code.gsub('<', '&lt;').gsub('>', '&gt;')
    end

    def list_all
      strs = {}
      @master_store.children.each do |c|
        strs.merge!(create_list(c))
      end

      str = ''

      Hash[strs.sort].each do |_, value|
        str += "#{value}\n"
      end

      str.rstrip!
      str
    end

    def erb_binding
      binding
    end

    private

    def create_list(store)
      strs = {}

      str = '<a id="lc-list" href="'
      str += "/#{store.path}.html"
      str += '">'
      str += format_rb_string(store.rb_string)
      str += '</a>'

      strs.store(store.rb_string, str)

      store.children.each do |c|
        strs.merge!(create_list(c))
      end

      strs
    end

    def format_rb_string(rb_string)
      parts = rb_string.split('::')
      str = ''
      (0..parts.length - 1).each do |i|
        str += parts[i]
        str += '&thinsp;<strong>::</strong>&thinsp;' if i < parts.length - 1
      end
      str
    end
  end
end
