require 'yaml'
require 'safe_yaml'

module Dockmaster
  # test
  # test
  # 3
  class Configuration
    DOTFILE = '.docmaster.yml'.freeze
    class << self
      # test again
      # test again
      def load_file
        dockmaster_yml = File.join(Dir.pwd, DOTFILE)

        # test
        hash = {}

        # test2
        if File.exist?(dockmaster_yml)
          yaml = IO.read(dockmaster_yml.path, encoding: 'UTF-8')
          hash = load_safe_yaml(yaml, dockmaster_yml.path)
        end

        @config = hash
      end

      # test again and again
      def load_safe_yaml(yaml, filename)
        if YAML.respond_to?(:safe_load)
          if defined?(SafeYAML) && SafeYAML.respond_to?(:load)
            SafeYAML.load(yaml, filename)
          else
            Yaml.safe_load(yaml, [Regexp], [], false, filename)
          end
        else
          YAML.load(yaml, filename)
        end
      end

      def test
      end
    end
  end
end
