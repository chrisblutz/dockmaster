require 'dockmaster/output/erb/base_helper'

RSpec.describe Dockmaster::BaseHelper do
  describe '#source' do
    it 'retrieves the source for the method' do
      source_str = <<-END
# Test documentation
module TestModule
  module_function

  # Test documentation
  def test_method
    test = 'test'
    puts test if true
  end
end
      END
      store = Dockmaster::Store.new(nil, :none, '')
      store = Dockmaster::DocParser.parse_string(source_str, store)

      expect(store.children).not_to be_empty

      mod_store = store.children[0]

      expect(mod_store.type).to eq(:module)

      helper = Dockmaster::BaseHelper.new(store, mod_store)

      unparsed_source = helper.source(:static_method, :test_method)

      expected = <<-END.rstrip
# File '<none>', line 6

def test_method
  test = "test"
  if true
    puts(test)
  end
end
      END

      expect(unparsed_source).to eq(expected)
    end
  end

  describe '#list_all_stores with multiple nested modules' do
    it 'correctly lists all stores' do
      source_str = <<-END
module Nest0
  module Nest1
    module Nest2
    end
  end
end
      END
      store = Dockmaster::Store.new(nil, :none, '')
      store = Dockmaster::DocParser.parse_string(source_str, store)

      mod_store = store.children[0]

      helper = Dockmaster::BaseHelper.new(store, mod_store)
      store_list = helper.list_all_stores

      nest0 = store_list[0]
      expect(nest0.name).to eq(:Nest0)
      nest1 = store_list[1]
      expect(nest1.name).to eq(:Nest1)
      nest2 = store_list[2]
      expect(nest2.name).to eq(:Nest2)
    end
  end
end
