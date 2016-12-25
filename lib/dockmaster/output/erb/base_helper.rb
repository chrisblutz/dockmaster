module Dockmaster
  # Represents the base helper for
  # ERB bindings
  class BaseHelper
    autoload :Unparser, 'unparser'

    def initialize(master_store, store)
      @master_store = master_store
      @store = store
    end

    def method_names
      Array.new(@store.method_data.keys).sort
    end

    def field_names
      Array.new(@store.field_data.keys).sort
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

    def list_all_stores
      stores = {} # < TODO:  TURN THIS INTO A HASH

      @master_store.children.each do |child|
        stores.merge!(create_store_list(child))
      end

      stores_arr = []

      Hash[stores.sort].each do |_, value|
        stores_arr << value
      end

      stores_arr
    end

    private

    def create_store_list(store)
      stores = { store.rb_string => store }

      store.children.each do |child|
        stores.merge!(create_store_list(child))
      end

      stores
    end
  end
end
