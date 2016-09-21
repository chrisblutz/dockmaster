module Dockmaster
  class Command
    class << self
      def subclasses
        @subclasses ||= []
      end

      def inherited(other)
        subclasses << other
      end
    end
  end
end
