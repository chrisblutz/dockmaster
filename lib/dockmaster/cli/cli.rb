module Dockmaster
  class CLI
    attr_reader :arguments
    attr_reader :options

    def initialize
      command_str = ARGV.shift unless ARGV.empty?
      @command = Build.class

      Command.subclasses.each do |klass|
        @command = klass if command_str == klass.command_name
      end

      parse_options
    end

    def execute
      @command.run(self)
      return 0
    rescue StandardError, SyntaxError => e
      $stderr.puts e.message
      $stderr.puts e.backtrace
      return 1
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
    end
  end
end
