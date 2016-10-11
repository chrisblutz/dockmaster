require 'dockmaster/cli/cli'
require 'dockmaster/cli/help_formatter'

module Dockmaster
  # This class handles options
  # passed to the command-line
  # interface
  class Options
    class << self
      def run_options(_cli, options)
        Dockmaster.debug = options[:debug] if options.key?(:debug)
        Dockmaster.serve_at_end if options[:serve]
        Dockmaster.no_build if options['no-build'.to_sym]

        return unless options[:help]

        HelpFormatter.print_help

        exit(0)
      end
    end
  end
end
