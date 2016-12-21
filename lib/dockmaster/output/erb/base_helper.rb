module Dockmaster
  # Represents the base helper for
  # ERB bindings
  class BaseHelper
    autoload :CGI, 'cgi'
    autoload :Unparser, 'unparser'

    def initialize(master_store, store)
      @master_store = master_store
      @store = store
    end

    def method_names
      @store.method_data.keys
    end

    def field_names
      @store.field_data.keys
    end

    def method_source(name)
      if @store.method_data.key?(name)
        data = @store.method_data[name]
        return data_source(data)
      end
      ''
    end

    def field_source(name)
      if @store.field_data.key?(name)
        data = @store.field_data[name]
        return data_source(data)
      end
      ''
    end

    def data_source(data)
      code = Unparser.unparse(data.ast)
      code = "# File '#{data.file.sub(Dir.pwd, '')}', line #{data.line}\n\n#{code}"
      code
    end

    def escape_html(str)
      CGI.escapeHTML(str)
    end

    def list_all_stores
      stores = []

      @master_store.children.each do |child|
        stores += create_store_list(child)
      end

      stores.sort_by(&:rb_string)

      stores
    end

    private

    def create_store_list(store)
      stores = [store]

      store.children.each do |child|
        stores += create_store_list(child)
      end

      stores
    end
  end
end
