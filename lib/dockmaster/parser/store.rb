module Dockmaster
  class Store
    class << self
      attr_reader :cache

      def in_cache?(parent, type, name)
        @cache ||= []

        @cache.each do |store|
          if (!store.parent.nil? && !parent.nil? && store.parent.similar?(parent)) || (store.parent.nil? && parent.nil?)
            return true if store.type == type && store.name == name
          end
        end

        false
      end

      def from_cache(parent, type, name)
        @cache ||= []

        @cache.each do |store|
          if (!store.parent.nil? && !parent.nil? && store.parent.similar?(parent)) || (store.parent.nil? && parent.nil?)
            return store if store.type == type && store.name == name
          end
        end

        new_store = Store.new(parent, type, name)
        @cache << new_store

        new_store
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

    private

    def append_field_and_method_strings(str, level)
      unless fields.empty?
        field_data.each do |name, data|
          str += "#{'  ' * level}(field, #{name}"
          str += ", #{data.docs.inspect}" unless data.docs.empty?
          str += ")\n"
        end
      end
      unless method_data.empty?
        method_data.each do |name, data|
          str += "#{'  ' * level}(method, #{name}"
          str += ", #{data.docs.inspect}" unless data.docs.empty?
          str += ")\n"
        end
      end

      str
    end
  end
end
