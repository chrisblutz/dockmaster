require 'dockmaster/docs/processor_defaults'

RSpec.describe Dockmaster::ProcessorDefaults do
  context 'with nested internal annotations' do
    it 'formats the text correctly' do
      src = '{@code {@code test}}'
      result = Dockmaster::DocProcessor.process_internal_documentation(src)

      expect(result).to eq(['<code><code>test</code></code>'])
    end
  end

  context 'with a multi-line internal annotation' do
    it 'formats the text correctly' do
      src = ['{@code code', 'test}']
      result = Dockmaster::DocProcessor.process_internal_documentation(src)

      expect(result).to eq(['<code>code', 'test</code>'])
    end
  end

  context 'with @code annotation' do
    it 'formats the text inside of a <code> tag' do
      src = '{@code test}'
      result = Dockmaster::DocProcessor.process_internal_documentation(src)

      expect(result).to eq(['<code>test</code>'])
    end
  end

  context 'with @pre annotation' do
    context 'without a CSS class defined' do
      it 'formats the text inside of <pre><code> tags' do
        src = <<-END
# {@pre
# module Test
#   class TestClass
#   end
# end
# }
        END
        result = Dockmaster::DocProcessor.process(src, '<none>')

        expected = '<pre><code>module Test<br>  class TestClass<br>  end<br>end</code></pre>'
        expect(result.description).to eq(expected)
      end
    end

    context 'with a CSS class defined' do
      it 'formats the text inside of a <pre> tag and a <code> tag with a class' do
        src = <<-END
# {@pre @lang-ruby
# module Test
#   class TestClass
#   end
# end
# }
          END
        result = Dockmaster::DocProcessor.process(src, '<none>')

        expected = '<pre><code class="lang-ruby">module Test<br>  class TestClass<br>  end<br>end</code></pre>'
        expect(result.description).to eq(expected)
      end
    end
  end

  context 'with @quote annotation' do
    it 'formats the text inside of a <blockquote> tag' do
      src = '{@quote test}'
      result = Dockmaster::DocProcessor.process_internal_documentation(src)

      expect(result).to eq(['<blockquote>test</blockquote>'])
    end
  end

  context 'with @link annotation' do
    it 'formats the text inside of an <a> tag' do
      src = '{@link example.com text}'
      result = Dockmaster::DocProcessor.process_internal_documentation(src)

      expect(result).to eq(['<a href="example.com">text</a>'])
    end
  end

  context 'with @see annotation' do
    it 'formats the text inside of an <a> tag and retrieves the correct URL' do
      src = '{@see Test::test}'
      Dockmaster::DocProcessor.see_links['Test::test'] = 'test'
      result = Dockmaster::DocProcessor.process_internal_documentation(src)

      expect(result).to eq(['<em>(see <a href="test">Test::test</a>)</em>'])
    end

    context 'with an incorrect reference' do
      it 'returns # for the link' do
        src = '{@see TestFail::test}'

        result = nil
        Dockmaster::External.silent_output do
          result = Dockmaster::DocProcessor.process_internal_documentation(src)
        end

        expect(result).to eq(['<em>(see <a href="#">TestFail::test</a>)</em>'])
      end
    end
  end

  context 'with @ext annotation' do
    context 'with .html input' do
      it 'imports the HTML correctly' do
        src = '# {@ext spec/files/doc-ext/incl-test.html}'
        result = Dockmaster::DocProcessor.process(src, '<none>')

        expect(result.description).to eq('This is a <code>test</code>.')
      end
    end

    context 'with .txt input' do
      it 'imports the text correctly, with internal docs parsed' do
        src = '# {@ext spec/files/doc-ext/incl-test.txt}'
        result = Dockmaster::DocProcessor.process(src, '<none>')

        expect(result.description).to eq('This is a <code>test</code>.')
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

  context 'with @api annotation' do
    it 'saves the correct api access level' do
      src = '# @api private'
      result = Dockmaster::DocProcessor.process(src, '<none>')

      expect(result[:api]).to eq(:private)
    end
  end
end
