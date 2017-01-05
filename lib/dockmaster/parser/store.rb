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
    attr_accessor :docs
    attr_writer :doc_str
    attr_writer :data
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

    def doc_str
      @doc_str ||= ''
    end

    def data
      @data ||= {}
    end

    def data_type(type)
      data[type] ||= {}
    end

    def name
      @name ||= ''
    end

    def type
      @type ||= :none
    end

    def parse_see_links
      out = Dockmaster::Theme.module_output(self) if @type == :module
      out = Dockmaster::Theme.class_output(self) if @type == :class
      out ||= '/'

      Dockmaster::DocProcessor.see_links[rb_string] = out

      data.each do |type, hash|
        hash.each do |name, _|
          link = "#{out}##{type}_#{name}"
          separator = ParserRegistry.separators[type]
          separator ||= '.'
          Dockmaster::DocProcessor.see_links["#{@rb_string}#{separator}#{name}"] = link
        end
      end

      children.each(&:parse_see_links)
    end

    def parse_docs
      unless @parent.nil?
        Dockmaster::CLI.debug "Processing documentation for #{@rb_string}"

        @docs = Dockmaster::DocProcessor.process(doc_str, @rb_string)

        data.each do |type, hash|
          hash.each do |name, data|
            separator = ParserRegistry.separators[type]
            separator ||= '.'
            data.docs = Dockmaster::DocProcessor.process(data.doc_str, "#{rb_string}#{separator}#{name}")
          end
        end
      end

      children.each(&:parse_docs)
    end

    def to_indented_string(level)
      indent = '  ' * level
      str = ''
      str += "#{indent}(#{type}, #{name}"
      str += ", has docs? #{!doc_str.empty?}"
      str += ")\n"
      str = append_internal_strings(str, level + 1)
      children.each do |child|
        str += child.to_indented_string(level + 1)
      end
      str
    end

    def inspect
      to_indented_string(0)
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

    def append_internal_strings(str, level)
      data.each do |type, hash|
        str = append_hash_docs(hash, str, type, level) unless hash.empty?
      end

      str
    end

    def append_hash_docs(hash_data, str, type, level)
      hash_data.each do |name, data|
        str += "#{'  ' * level}(#{type}, #{name}"
        str += ', private' if data.private
        str += ', read-only' if data.readonly?
        str += ", has docs? #{!data.doc_str.empty?}"
        str += ")\n"
      end

      str
    end
  end
end
