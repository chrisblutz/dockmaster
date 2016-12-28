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
    it 'returns a correctly formatted string' do
      src = <<-END
# Documentation
module Test
  TEST = 'test'.freeze

  # A field with docs
  TEST_W_DOCS = 'test'.freeze

  # More documentation
  class TestClass
    attr_reader :test_field

    def method
    end

    # Method with docs
    def self.method_w_docs
    end
  end
end
      END

      store = Dockmaster::Store.new(nil, :none, '')
      store = Dockmaster::DocParser.parse_string(src, store)

      exp = <<-END
(none, , has docs? false)
  (module, Test, has docs? true)
    (constant, TEST, has docs? false)
    (constant, TEST_W_DOCS, has docs? true)
    (class, TestClass, has docs? true)
      (instance_field, test_field, read-only, has docs? false)
      (instance_method, method, has docs? false)
      (static_method, method_w_docs, has docs? true)
      END

      expect(store.inspect).to eq(exp)
    end
  end
end
