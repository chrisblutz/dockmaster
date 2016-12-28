require 'stringio'
require 'fileutils'

RSpec.describe Dockmaster::Output do
  context 'using default HTML theme' do
    context 'with blank input' do
      it 'creates only an \'index.html\' file' do
        store = Dockmaster::DocParser.parse_string('', Dockmaster::Store.new(nil, :none, ''))

        Dockmaster::Output.start_processing(store)

        entries = Dir["#{Dockmaster::CONFIG[:output]}/*.html"]
        entries.delete('.')
        entries.delete('..')

        expect(entries).to eq(["#{Dockmaster::CONFIG[:output]}/index.html"])
      end
    end

    context 'with one module and one class' do
      it 'creates an \'index.html\' and module/class files' do
        src = <<-END
module Test
  class TestClass
  end
end
        END
        store = Dockmaster::DocParser.parse_string(src, Dockmaster::Store.new(nil, :none, ''))

        store.parse_see_links
        store.parse_docs

        Dockmaster::Output.start_processing(store)

        entries = Dir["#{Dockmaster::CONFIG[:output]}/**/*.html"]
        entries.delete('.')
        entries.delete('..')

        output = Dockmaster::CONFIG[:output]
        ary = ["#{output}/index.html", "#{output}/Test/TestClass.html", "#{output}/Test.html"]

        expect(entries).to eq(ary)
      end
    end
  end
end
