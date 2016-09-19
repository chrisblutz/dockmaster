module Dockmaster
  class Storage
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
