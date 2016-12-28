module Dockmaster
  # Represents the base helper for
  # ERB bindings
  class BaseHelper
    autoload :Unparser, 'unparser'

    def initialize(master_store, store)
      @master_store = master_store
      @store = store
    end

    def names(type)
      Array.new(@store.data_type(type).keys).sort
    end

    def source(type, name)
      data = @store.data_type(type)[name]
      return '' if data.nil?
      data_source(data)
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
