module Dockmaster
  # This enforcer class checks documentation on modules/classes
  class ModuleClassEnforcer
    class << self
      def matches(type)
        type == :module || type == :class
      end

      def check(store, criteria)
        criteria.define_scope(store.rb_string)

        criteria.define_new(:description, 'General description')
        criteria.set(:description, !store.docs.description.empty?)

        criteria
      end
    end
  end
end
