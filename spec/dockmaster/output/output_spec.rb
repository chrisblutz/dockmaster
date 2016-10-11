require 'stringio'
require 'fileutils'

RSpec.describe Dockmaster::Output do
  context 'with blank input' do
    it 'creates only an \'index.html\' file' do
      store = Dockmaster::DocParser.parse_string('', Dockmaster::Store.new(nil, :none, ''))

      Dockmaster::Output.start_processing(store)

      entries = Dir.entries('rspec/tests/files')
      entries.delete('.')
      entries.delete('..')

      expect(entries).to eq(['index.html'])

      FileUtils.rm_rf('rspec')
    end
  end

  context 'with one module' do
    it 'creates an \'index.html\' and module files' do
      store = Dockmaster::DocParser.parse_string('module Test; end', Dockmaster::Store.new(nil, :none, ''))

      Dockmaster::Output.start_processing(store)

      entries = Dir.entries('rspec/tests/files')
      entries.delete('.')
      entries.delete('..')

      expect(entries).to include('index.html', 'Test.html')

      FileUtils.rm_rf('rspec')
    end
  end
end
