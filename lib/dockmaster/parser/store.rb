module Dockmaster
  # Represents the storage
  # container for parsed
  # source files
  class Store
    class << self
      attr_reader :cache

      def in_cache?(parent, type, name)
        @cache ||= []

        @cache.each do |store|
          return true if exists_in_cache?(parent, type, name, store)
        end

        false
      end

      def from_cache(parent, type, name)
        @cache ||= []

        @cache.each do |store|
          return store if exists_in_cache?(parent, type, name, store)
        end

        new_store = Store.new(parent, type, name)
        @cache << new_store

        new_store
      end

      def clear_cache
        @cache = []
      end

      private

      def exists_in_cache?(parent, type, name, store)
        if (!store.parent.nil? && !parent.nil? && store.parent.similar?(parent)) || (store.parent.nil? && parent.nil?)
          return true if store.type == type && store.name == name
        end

        false
      end
    end

    attr_reader :parent
    attr_reader :path
    attr_reader :rb_string
    attr_writer :children
    attr_writer :docs
    attr_writer :field_data
    attr_writer :method_data
    attr_writer :type

    def initialize(parent, type, name)
      @parent = parent
      @type = type
      @name = name
      unless parent.nil?
        @path = if parent.path.nil?
                  ''
                else
                  parent.path + File::SEPARATOR
                end
        @rb_string = if parent.rb_string.nil?
                       ''
                     else
                       parent.rb_string + '::'
                     end
      end
      @path += name.to_s unless @path.nil?
      @rb_string += name.to_s unless @rb_string.nil?
    end

    def children
      @children ||= []
    end

    def docs
      @docs ||= ''
    end

    def field_data
      @field_data ||= {}
    end

    def method_data
      @method_data ||= {}
    end

    def name
      @name ||= ''
    end

    def type
      @type ||= :none
    end

    def to_indented_string(level)
      indent = '  ' * level
      str = ''
      str += "#{indent}(#{type}, #{name}"
      str += ", #{docs.inspect}" unless docs.empty?
      str += ")\n"
      str = append_field_and_method_strings(str, level + 1)
      children.each do |child|
        str += child.to_indented_string(level + 1)
      end
      str
    end

    def inspect
      to_indented_string(0)
    end

    def erb_binding
      binding
    end

    def similar?(other)
      return false if other.rb_string != @rb_string
      return false if other.type != type
      return false if other.name != name
      true
    end

    def ==(other)
      return false if other.parent != @parent
      return false unless similar?(other)
      true
    end

    private

    def append_field_and_method_strings(str, _level)
      str = append_hash_docs(field_data, str, :field) unless field_data.empty?
      str = append_hash_docs(method_data, str, :module) unless method_data.empty?

      str
    end

    def append_hash_docs(hash_data, str, type)
      hash_data.each do |name, data|
        str += "#{'  ' * level}(#{type}, #{name}"
        str += ", #{data.docs.inspect}" unless data.docs.empty?
        str += ")\n"
      end

      str
    end
  end
end
