module Dockmaster
  # Represents the 'theme' command
  # that generates a blank theme
  # for Dockmaster
  class ThemeCommand < Command
    class << self
      def command_name
        'theme'
      end

      def run(_cli)
        puts '[ThemeCommand] This feature has not been implemented yet!'
      end
    end
  end
end
