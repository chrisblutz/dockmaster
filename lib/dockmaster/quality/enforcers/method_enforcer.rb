module Dockmaster
  # This enforcer class checks documentation on methods
  class MethodEnforcer
    class << self
      def matches(type)
        type == :static_method || type == :instance_method
      end

      def check(type, name, data, parent, criteria)
        separator = ParserRegistry.separators[type]
        separator ||= '.'
        criteria.define_scope("#{parent.rb_string}#{separator}#{name}")

        criteria.define_new(:description, 'General description')
        criteria.set(:description, !data.docs.description.empty?)

        unless data.args.empty?
          criteria.define_new(:params, 'Parameter descriptions')
          criteria.set(:params, !data.docs[:params].nil? && !data.docs[:params].empty?)
        end

        criteria.define_new(:return, 'Return value description')
        criteria.set(:return, !data.docs[:return].nil? && !data.docs[:return].empty?)

        criteria
      end
    end
  end
end
