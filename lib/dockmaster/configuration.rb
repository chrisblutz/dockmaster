require 'yaml'
require 'safe_yaml'

module Dockmaster
  # Represents the configuration
  # file (.dockmaster.yml) for the project
  class Configuration
    DOTFILE = '.dockmaster.yml'.freeze
    class << self
      def load_file
        dockmaster_yml = File.join(Dir.pwd, DOTFILE)

        hash = {}

        if File.exist?(dockmaster_yml)
          yaml = IO.read(dockmaster_yml, encoding: 'UTF-8')
          hash = load_safe_yaml(yaml, dockmaster_yml)
        end

        Configuration.new(hash)
      end

      def load_safe_yaml(yaml, filename)
        SafeYAML.load(yaml, filename)
      end
    end

    attr_accessor :title
    attr_accessor :output_dir
    attr_accessor :full_output_dir
    attr_accessor :excluded_files

    def initialize(hash)
      @title = "#{File.basename(Dir.pwd)} Documentation"
      @title = hash['title'] if hash.key?('title')
      @output_dir = 'doc'
      @output_dir = hash['output_dir'].chomp('/').chomp('\\') if hash.key?('output_dir')
      @full_output_dir = File.join(Dir.pwd, @output_dir)
      @excluded_files = []
      @excluded_files = hash['exclude'] if hash.key?('exclude')
    end

    def excluded?(file)
      @excluded_files.each do |ex|
        return true if file.start_with?(File.join(Dir.pwd, ex))
      end

      false
    end
  end
end
