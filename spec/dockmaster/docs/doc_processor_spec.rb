RSpec.describe Dockmaster::ProcessorDefaults do
  context 'with multi-line documentation with an empty line' do
    it 'formats the text correctly' do
      src = <<-END
# Test
#
# test
      END
      result = Dockmaster::DocProcessor.process(src, '<none>')

      expect(result.description).to eq('Test <br><br>test')
    end
  end
end
