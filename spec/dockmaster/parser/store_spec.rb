require 'fileutils'

RSpec.describe Dockmaster::Store do
  context 'if cache is cleared' do
    it 'is empty' do
      default_store = Dockmaster::Store.new(nil, :none, '')
      default_store.children << Dockmaster::Store.new(default_store, :module, 'Test')

      Dockmaster::Store.clear_cache

      expect(Dockmaster::Store.in_cache?(default_store, :module, 'Test')).to be_falsey
    end
  end

  context 'if a Store is not in the cache' do
    it 'returns a Store with the given parameters' do
      Dockmaster::Store.clear_cache
      default_store = Dockmaster::Store.new(nil, :none, '')
      store = Dockmaster::Store.from_cache(default_store, :module, 'Test')

      store_check = Dockmaster::Store.new(default_store, :module, 'Test')

      expect(store).to eq(store_check)
    end
  end

  describe '#inspect' do
    it 'returns a formatted string' do
      source_str = <<-END
# Test documentation
module TestModule
  # Test documentation
  TEST_FIELD = 0

  # Test documentation
  def test_method
  end
end
      END
      store = Dockmaster::Store.new(nil, :none, '')
      store = Dockmaster::DocParser.parse_string(source_str, store)

      str = store.inspect

      expected = <<-END
(none, )
  (module, TestModule, "# Test documentation")
    (field, TEST_FIELD, "# Test documentation")
    (module, test_method, "# Test documentation")
      END

      expect(str).to eq(expected)
    end
  end
end
