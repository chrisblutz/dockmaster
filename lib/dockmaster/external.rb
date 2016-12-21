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
          puts "Loading theme '#{Dockmaster::CONFIG[:theme]}', using path '#{theme}'..." if Dockmaster.debug?
          require(theme)
        rescue LoadError
          error = <<-END
Cannot find theme '#{Dockmaster::CONFIG[:theme]}'.  It may be contained in a gem such as 'dockmaster-theme-#{Dockmaster::CONFIG[:theme]}'.
          END
          abort error
        end
      end

      def load_plugins
        plugins = Dockmaster::CONFIG[:plugins]
        return unless !plugins.nil? && plugins.is_a?(Array)
        plugins.each do |plugin|
          plugin_full = "dockmaster/#{plugin}"
          begin
            puts "Loading plugin '#{plugin}', using path '#{plugin_full}'..." if Dockmaster.debug?
            require(plugin_full)
          rescue LoadError
            error = <<-END
Cannot find plugin '#{plugin}'.  It may be contained in a gem such as 'dockmaster-#{plugin}'.
              END
            abort error
          end
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
