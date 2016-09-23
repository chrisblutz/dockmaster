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
      source_str = <<-RUBY
module TestModule
end
      RUBY

      store = Dockmaster::DocParser.parse_string(source_str, default_store)

      expect(store.children).not_to be_empty

      mod_store = store.children[0]

      expect(mod_store.type).to eq(:module)
      expect(mod_store.name).to eq(:TestModule)
    end
  end

  context 'with one module with documentation'
  it 'returns a Store with one module with the same documentation' do
    source_str = <<-RUBY
# Documentation
module TestModule
end
      RUBY

    store = Dockmaster::DocParser.parse_string(source_str, default_store)

    expect(store.children).not_to be_empty

    mod_store = store.children[0]

    expect(mod_store.type).to eq(:module)
    expect(mod_store.docs).to eq('# Documentation')
  end
end
