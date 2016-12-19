require 'dockmaster/cli/options'

require 'webrick'

module Dockmaster
  # Represents the command-line
  # interface and helps parse options
  # for commands
  class CLI
    attr_reader :arguments
    attr_reader :options

    def initialize
      parse_options

      return if @arguments.empty? || @arguments[0].start_with?('--')

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

    def build_docs
      store = Dockmaster::DocParser.begin
      Dockmaster::Output.start_processing(store)
      puts 'Documentation built successfully!'
    end

    def serve_docs
      root = File.expand_path(File.join(Dir.pwd, Dockmaster::CONFIG[:output]))
      server = WEBrick::HTTPServer.new Port: 8000, DocumentRoot: root
      trap 'INT' do
        server.shutdown
      end
      server.start
    end

    private

    def parse_options
      @arguments = []
      @options = {}
      current_arg = nil
      ARGV.each do |arg|
        if arg.start_with?('--')
          option_sym = arg[2..-1].to_sym
          @options[option_sym] = []
          current_arg = option_sym
        elsif current_arg.nil?
          @arguments << arg
        else
          @options[current_arg] << arg
        end
      end

      Options.run_options(self, @options)
    end
  end
end
