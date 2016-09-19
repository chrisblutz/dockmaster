module Dockmaster
  class Store
    class << self
      def squash(stores)
        final = stores.shift unless stores.empty?
        stores.each do |store|
          final = perform_squash(final, store)
        end

        final
      end

      private

      def perform_squash(to, from)
        if to.similar?(from)
          to.children += from.children
          to.docs = from.docs unless from.docs.empty?
          to.children.each do |to_c|
            from.children.each do |from_c|
              to_c = perform_squash(to_c, from_c)
            end
          end
        end
        to
      end
    end

    attr_reader :parent
    attr_reader :path
    attr_reader :rb_string
    attr_writer :children
    attr_writer :docs
    attr_writer :fields
    attr_writer :methods
    attr_writer :name
    attr_writer :type

    def initialize(parent)
      @parent = parent
      return if parent.nil?
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

    def children
      @children ||= []
    end

    def docs
      @docs ||= ''
    end

    def fields
      @fields ||= {}
    end

    def methods
      @methods ||= {}
    end

    def name=(name)
      @name = name
      @path += name.to_s unless @path.nil?
      @rb_string += name.to_s unless @rb_string.nil?
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
      return false if other.type != type
      return false if other.name != name

      true
    end

    def children_contains?(store)
      children.each do |child|
        return true if child.similar?(store)
      end
      false
    end

    def merge_children(store)
      children.each do |child|
        if child.similar?(store)
          child.children += store.children
          child.docs = store.docs unless store.docs.empty?
        end
      end
    end

    def merge_data(store)
      fields.merge!(store.fields)
      methods.merge!(store.methods)
      @docs = store.docs unless store.docs.empty?
    end

    private

    def append_field_and_method_strings(str, level)
      unless fields.empty?
        fields.each do |name, docs|
          str += "#{'  ' * level}(field, #{name}"
          str += ", #{docs.inspect}" unless docs.empty?
          str += ")\n"
        end
      end
      unless methods.empty?
        methods.each do |name, docs|
          str += "#{'  ' * level}(method, #{name}"
          str += ", #{docs.inspect}" unless docs.empty?
          str += ")\n"
        end
      end

      str
    end
  end
end
