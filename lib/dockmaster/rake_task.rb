require 'rake'
require 'rake/tasklib'

module Dockmaster
  # This class provides a custom Rake task for documentation generation through Dockmaster
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    attr_accessor :title
    attr_accessor :output
    attr_accessor :theme
    attr_accessor :verbose
    attr_accessor :exclude
    attr_accessor :params

    def initialize(*args, &block)
      setup_args(args)

      desc 'Run Dockmaster'

      task(@name, *args) do |_, task_args|
        RakeFileUtils.send(:verbose, @verbose) do
          yield(*[self, task_args].slice(0, block.arity)) if block_given?

          run_dockmaster
        end
      end
    end

    private

    def run_dockmaster
      require 'dockmaster'

      # Override configurations if they were set in the Rake task,
      # otherwise leave values in .dockmaster.yml (if it exists)
      Dockmaster::CONFIG[:title] = @title unless @title.empty?
      Dockmaster::CONFIG[:output] = @output unless @output.empty?
      Dockmaster::CONFIG[:theme] = @theme unless @theme.empty?
      Dockmaster::CONFIG[:exclude] = @title unless @exclude.empty?

      puts 'Generating documentation...'
      strip_invalid_params
      cli = Dockmaster::CLI.new(@params)
      Dockmaster.load_externals
      result = cli.execute
      abort('Dockmaster exited with errors!') if result.nonzero?
    end

    def strip_invalid_params
      return unless @params.include?('--serve') || @params.include?('-s')

      puts 'NOTE: Dockmaster prohibits the use of --serve/-s options while running through Rake.'\
           '  Please run Dockmaster through its own command to use these options.'

      @params.delete('--serve')
      @params.delete('-s')
    end

    def setup_args(args)
      @name = args.shift || :dockmaster

      @title = ''
      @output = ''
      @theme = ''
      @verbose = true
      @exclude = []
      @params = []
    end
  end
end
