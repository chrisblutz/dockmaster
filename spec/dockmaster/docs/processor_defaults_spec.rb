require 'dockmaster/docs/processor_defaults'

RSpec.describe Dockmaster::ProcessorDefaults do
  context 'with @code annotation' do
    it 'formats the text inside of a <code> tag' do
      src = '{@code test}'
      result = Dockmaster::DocProcessor.process_internal_documentation(src)

      expect(result).to eq('<code>test</code>')
    end
  end

  context 'with @link annotation' do
    it 'formats the text inside of an <a> tag' do
      src = '{@link example.com text}'
      result = Dockmaster::DocProcessor.process_internal_documentation(src)

      expect(result).to eq('<a href="example.com">text</a>')
    end
  end

  context 'with @see annotation' do
    it 'formats the text inside of an <a> tag and retrieves the correct URL' do
      src = '{@see Test::test}'
      Dockmaster::DocProcessor.see_links['Test::test'] = 'test'
      result = Dockmaster::DocProcessor.process_internal_documentation(src)

      expect(result).to eq('<em>(see <a href="test">Test::test</a>)</em>')
    end

    context 'with an incorrect reference' do
      it 'returns # for the link' do
        src = '{@see TestFail::test}'

        result = nil
        Dockmaster::External.silent_output do
          result = Dockmaster::DocProcessor.process_internal_documentation(src)
        end

        expect(result).to eq('<em>(see <a href="#">TestFail::test</a>)</em>')
      end
    end
  end

  context 'with @param annotation' do
    it 'processes the param name and description' do
      src = '# @param test desc'
      result = Dockmaster::DocProcessor.process(src, '<none>')

      expect(result[:params]).to eq('test' => 'desc')
    end
  end

  context 'with @author annotation' do
    it 'saves the author\'s name' do
      src = '# @author test'
      result = Dockmaster::DocProcessor.process(src, '<none>')

      expect(result[:author]).to eq('test')
    end
  end

  context 'with @return annotation' do
    it 'saves the return value\'s description' do
      src = '# @return test'
      result = Dockmaster::DocProcessor.process(src, '<none>')

      expect(result[:return]).to eq('test')
    end
  end
end
