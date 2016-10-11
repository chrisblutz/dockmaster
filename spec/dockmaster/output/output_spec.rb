require 'stringio'

RSpec.describe Dockmaster::Output do
  default_store = Dockmaster::Store.new(nil, :none, '')

  context 'with blank input' do
    it 'creates only an \'index.html\' file' do
      store = Dockmaster::DocParser.parse_string('', default_store)

      Dockmaster::Output.start_processing(store)

      entries = Dir.entries('rspec/tests/files')
      entries.delete('.')
      entries.delete('..')

      expect(entries).to eq(['index.html'])
    end
  end

  context 'with one module' do
    it 'creates an \'index.html\' and module files' do
      store = Dockmaster::DocParser.parse_string('module Test; end', default_store)

      Dockmaster::Output.start_processing(store)

      entries = Dir.entries('rspec/tests/files')
      entries.delete('.')
      entries.delete('..')

      expect(entries).to include('index.html', 'Test.html')
    end
  end
end
