require 'fileutils'

RSpec.describe Dockmaster::DocParser do
  default_store = Dockmaster::Store.new(nil, :none, '')

  context 'with blank input' do
    it 'returns the default empty Store' do
      store = Dockmaster::DocParser.parse_string('', default_store)

      expect(store).to eq(default_store)
    end
  end

  context 'with one module' do
    it 'returns a Store with one module' do
      source_str = <<-END
module TestModule
end
      END

      store = Dockmaster::Store.new(nil, :none, '')
      store = Dockmaster::DocParser.parse_string(source_str, store)

      expect(store.children).not_to be_empty

      mod_store = store.children[0]

      expect(mod_store.type).to eq(:module)
      expect(mod_store.name).to eq(:TestModule)
    end
  end

  context 'with one module with documentation' do
    it 'returns a Store with one module with the same documentation' do
      source_str = <<-END
# Documentation
module TestModule
end
      END

      store = Dockmaster::Store.new(nil, :none, '')
      store = Dockmaster::DocParser.parse_string(source_str, store)

      expect(store.children).not_to be_empty

      mod_store = store.children[0]

      expect(mod_store.type).to eq(:module)
      expect(mod_store.name).to eq(:TestModule)
      expect(mod_store.docs).to eq('# Documentation')
    end
  end

  context 'with a file containing one module' do
    it 'returns a Store with one module' do
      store = Dockmaster::Store.new(nil, :none, '')
      store = Dockmaster::DocParser.parse_file(File.join(Dir.pwd, 'spec/files/testfile_doc_parser.rb'), store)

      expect(store.children).not_to be_empty

      mod_store = store.children[0]

      expect(mod_store.type).to eq(:module)
      expect(mod_store.name).to eq(:TestModule)
      expect(mod_store.docs).to eq('# Documentation')
    end
  end

  describe 'begin' do
    it 'finds all source files and parses them into a Store' do
      Dir.chdir('spec/files/parser_test') do
        store = Dockmaster::DocParser.begin

        expected = <<-END
(none, )
  (module, TestFiles)
    (class, TestFile1, "# Test documentation for TestFile1")
      (field, TEST1, "# A field (1)")
      (method, test_method_1, "# A method (1)")
    (class, TestFile2, "# Test documentation for TestFile2")
      (field, TEST2, "# A field (2)")
      (method, test_method_2, "# A method (2)")
        END

        expect(store.inspect).to eq(expected)
      end
    end
  end
end
