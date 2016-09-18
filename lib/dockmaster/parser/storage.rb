module Dockmaster
  class Storage
    class Container
      attr_writer :children
      attr_writer :docs
      attr_writer :fields
      attr_writer :name
      attr_writer :type

      def children
        @children ||= []
      end

      def docs
        @docs ||= ''
      end

      def fields
        @fields ||= {}
      end

      def name
        @name ||= ''
      end

      def type
        @type ||= :none
      end
    end

    class << self
      attr_writer :containers

      def containers
        @containers ||= []
      end
    end
  end
end
