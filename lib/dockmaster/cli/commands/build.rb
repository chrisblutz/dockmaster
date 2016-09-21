module Dockmaster
  class Build < Command
    class << self
      def command_name
        'build'
      end

      def run(_cli)
        store = Dockmaster::DocParser.begin
        Dockmaster::Output.start_processing(store)
      end
    end
  end
end
