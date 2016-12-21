RSpec.describe Dockmaster::Plugin do
  # This class is for testing purposes only
  class TestPlugin < Dockmaster::Plugin
    class << self
      def load(manager)
        manager.register_handler(:docs_output, TestPlugin)
      end

      def id
        'test'
      end

      attr_reader :docs_output_fired, :misc_generation_fired

      def docs_output(_file, _output_str, _store)
        @docs_output_fired = true
      end

      def misc_generation(_master_store, _output)
        @misc_generation_fired = true
      end
    end
  end

  context 'with TestPlugin' do
    it 'shows one plugin is loaded' do
      expect Dockmaster::Plugin.loaded.length == 1
    end

    context 'with :docs_output handler' do
      it 'fires the handler method' do
        Dockmaster::Plugin.fire_event(:docs_output, '', '', nil)
        expect(TestPlugin.docs_output_fired).to eq(true)
      end
    end

    context 'with .misc_generation method' do
      it 'fires the method' do
        Dockmaster::Plugin.fire_misc_generation(nil, Dockmaster::Theme.base_template)
        expect(TestPlugin.misc_generation_fired).to eq(true)
      end
    end
  end
end
