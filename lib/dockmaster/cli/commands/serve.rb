require 'webrick'

module Dockmaster
  # Represents the 'serve' command, which
  # launches a WEBrick server that hosts the
  # documentation pages for viewing
  class Serve < Command
    class << self
      def command_name
        'serve'
      end

      def run(_cli)
        root = File.expand_path(File.join(Dir.pwd, Dockmaster::CONFIG.output_dir))
        server = WEBrick::HTTPServer.new Port: 8000, DocumentRoot: root
        trap 'INT' do
          server.shutdown
        end
        server.start
      end
    end
  end
end
