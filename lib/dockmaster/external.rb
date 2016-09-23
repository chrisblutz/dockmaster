require 'stringio'

module Dockmaster
  # Helps with requiring dependencies
  # without them throwing warnings
  # that clutter the output
  class External
    class << self
      def require_without_warnings(req)
        silent_warnings do
          require(req)
        end
      end

      private

      def silent_warnings
        old_stderr = $stderr
        $stderr = StringIO.new
        yield
      ensure
        $stderr = old_stderr
      end
    end
  end
end
