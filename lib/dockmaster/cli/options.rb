require 'dockmaster/cli/cli'
require 'dockmaster/cli/help_formatter'

module Dockmaster
  # This class handles options
  # passed to the command-line
  # interface
  class Options
    class << self
      def run_options(_cli, short_options, options)
        Dockmaster.debug if options.key?(:debug) || short_options.key?(:d)
        Dockmaster.serve_at_end if options[:serve] || short_options.key?(:s)
        Dockmaster.no_build if options['no-build'.to_sym] || short_options.key?(:n)
        Dockmaster.include_private if options['include-private'.to_sym] || short_options.key?(:p)
        puts "Dockmaster v#{Dockmaster::VERSION}" if options[:version] || short_options.key?(:v)

        return unless options[:help]

        HelpFormatter.print_help

        exit(0)
      end
    end
  end
end
