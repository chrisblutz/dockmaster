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

      def load_theme
        theme = Dockmaster::CONFIG[:theme]
        theme ||= 'default'
        theme = "dockmaster/theme/#{theme}"
        begin
          require(theme)
        rescue LoadError
          error = <<-END
Cannot find theme '#{Dockmaster::CONFIG[:theme]}'.  It may be contained in a gem such as 'dockmaster-theme-#{Dockmaster::CONFIG[:theme]}'.
          END
          abort error
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
