require 'dockmaster/cli/cli'
require 'dockmaster/cli/command'
require 'dockmaster/quality/quality_check'

module Dockmaster
  # This command class checks the quality of documentation within a project
  class Check < Command
    class << self
      def command_name
        'check'
      end

      def run(cli)
        CLI.output('Checking documentation...')
        store = Dockmaster::DocParser.begin
        QualityCheck.check(store)
        suggestions = cli.short_options[:u] || cli.options[:suggestions]
        QualityCheck.print_results(suggestions)
      end
    end
  end
end
