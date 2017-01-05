module Dockmaster
  # This enforcer class checks documentation on fields
  class FieldEnforcer
    class << self
      def matches(type)
        type == :static_field || type == :instance_field || type == :constant
      end

      def check(type, name, data, parent, criteria)
        separator = ParserRegistry.separators[type]
        separator ||= '.'
        criteria.define_scope("#{parent.rb_string}#{separator}#{name}")

        criteria.define_new(:description, 'General description')
        criteria.set(:description, !data.docs.description.empty?)

        criteria
      end
    end
  end
end
