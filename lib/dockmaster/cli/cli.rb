require 'dockmaster/cli/options'
require 'dockmaster/cli/commands/check'

require 'rainbow'
require 'rbconfig'
require 'webrick'

module Dockmaster
  # Represents the command-line
  # interface and helps parse options
  # for commands
  class CLI
    attr_reader :command_args
    attr_reader :arguments
    attr_reader :options
    attr_reader :short_options

    def initialize(command_args)
      @command_args = command_args

      parse_options

      return if @arguments.empty? || @arguments[0].start_with?('--') || @arguments[0].start_with?('-')

      command_str = @arguments[0]

      Command.subclasses.each do |klass|
        @command = klass if command_str == klass.command_name
      end

      @arguments.shift unless @command.nil?
    end

    def execute
      if @command.nil?
        # Build if no command
        build_docs unless Dockmaster.no_build?
      else
        @command.run(self)
      end
      return 0
    rescue StandardError, SyntaxError => e
      $stderr.puts e.message
      $stderr.puts e.backtrace
      return 1
    end

    def error(result)
      puts "Dockmaster encountered an error #{Rainbow("(exit code #{result})").yellow}"
    end

    def build_docs
      store = Dockmaster::DocParser.begin
      Dockmaster::Output.start_processing(store)
      CLI.end_bar
      files_str = Rainbow("#{Dockmaster::Output.generated} files").yellow
      CLI.output "Documentation built, #{files_str} generated"
      CLI.output "Generated site can be found in: #{Dockmaster::Output.docs_dir}"
    end

    def serve_docs
      root = File.expand_path(File.join(Dir.pwd, Dockmaster::CONFIG[:output]))
      log_file = 'NUL' if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
      log_file ||= '/dev/null'
      server = WEBrick::HTTPServer.new(Port: 8000,
                                       BindAddress: 'localhost',
                                       DocumentRoot: root,
                                       Logger: WEBrick::Log.new(log_file),
                                       AccessLog: [])
      trap 'INT' do
        server.shutdown
        CLI.output 'Documentation server shut down.'
      end
      CLI.output '-----------------'
      CLI.output ' Serving docs...'
      CLI.output '-----------------'
      CLI.output "Server open at '#{server.config[:BindAddress]}:#{server.config[:Port]}'."
      server.start
    end

    private

    def parse_options
      @arguments = []
      @options = {}
      @short_options = {}
      @short_current = false
      @current_arg = nil
      @command_args.each do |arg|
        if arg.start_with?('--')
          parse_option_indiv(arg[2..-1], false)
        elsif arg.start_with?('-')
          parse_option_indiv(arg[1..-1], true)
        elsif @current_arg.nil?
          @arguments << arg
        else
          @options[@current_arg] << arg unless @short_current
          @short_options[@current_arg] << arg if @short_current
        end
      end

      Options.run_options(self, @short_options, @options)
    end

    def parse_option_indiv(arg, short)
      option_sym = arg.to_sym
      if short
        @short_options[option_sym] = []
        @short_current = true
      else
        @options[option_sym] = []
        @short_current = false
      end
      @current_arg = option_sym
    end

    class << self
      def increment_progress
        increment(Rainbow('.').green) unless Dockmaster.debug? || Dockmaster.no_output?
      end

      def end_bar
        puts '' unless Dockmaster.debug? || Dockmaster.no_output?
      end

      def output(message)
        puts message unless Dockmaster.no_output?
      end

      def increment(message)
        print message unless Dockmaster.no_output?
      end

      def debug(message)
        puts message unless !Dockmaster.debug? || Dockmaster.no_output?
      end
    end
  end
end
