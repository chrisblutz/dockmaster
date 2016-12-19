require 'cogwheels'

module Dockmaster
  # Loads the configuration file and holds utility methods for dealing with the resulting object
  class Configuration
    DOTFILE = '.dockmaster.yml'.freeze
    class << self
      def load_file
        dockmaster_yml = File.join(Dir.pwd, DOTFILE)

        Cogwheels.load(dockmaster_yml).to_symbol_keys if File.exist?(dockmaster_yml)
      end

      def excluded?(file)
        Dockmaster::CONFIG[:exclude].each do |ex|
          return true if file.start_with?(File.join(Dir.pwd, ex))
        end

        false
      end
    end
  end
end
