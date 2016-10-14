require 'dockmaster/output/erb/site_binding'

RSpec.describe Dockmaster::SiteBinding do
  describe '#render_method' do
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

      binding = Dockmaster::SiteBinding.new(store, mod_store, nil)

      unparsed_source = binding.render_method(:test_method)

      expected = <<-END.rstrip
# File '&lt;none&gt;', line 4

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

  describe '#render_field' do
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

      binding = Dockmaster::SiteBinding.new(store, mod_store, nil)

      unparsed_source = binding.render_field(:TEST_FIELD)

      expected = <<-END.rstrip
# File '&lt;none&gt;', line 4

TEST_FIELD = 10.0
      END

      expect(unparsed_source).to eq(expected)
    end
  end
end
