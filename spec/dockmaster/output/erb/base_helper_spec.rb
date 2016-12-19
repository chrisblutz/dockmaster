require 'dockmaster/output/erb/base_helper'

RSpec.describe Dockmaster::BaseHelper do
  describe '#method_source' do
    it 'retrieves the source for the method' do
      source_str = <<-END
# Test documentation
module TestModule
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

      unparsed_source = helper.method_source(:test_method)

      expected = <<-END.rstrip
# File &#39;&lt;none&gt;&#39;, line 4

def test_method
  test = &quot;test&quot;
  if true
    puts(test)
  end
end
      END

      expect(unparsed_source).to eq(expected)
    end
  end

  describe '#field_source' do
    it 'retrieves the source for the field' do
      source_str = <<-END
# Test documentation
module TestModule
  # Test documentation
  TEST_FIELD = 10.0
end
      END
      store = Dockmaster::Store.new(nil, :none, '')
      store = Dockmaster::DocParser.parse_string(source_str, store)

      expect(store.children).not_to be_empty

      mod_store = store.children[0]

      expect(mod_store.type).to eq(:module)

      helper = Dockmaster::BaseHelper.new(store, mod_store)

      unparsed_source = helper.field_source(:TEST_FIELD)

      expected = <<-END.rstrip
# File &#39;&lt;none&gt;&#39;, line 4

TEST_FIELD = 10.0
      END

      expect(unparsed_source).to eq(expected)
    end
  end
end
