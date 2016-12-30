require 'stringio'
require 'fileutils'

RSpec.describe Dockmaster::Output do
  context 'using default HTML theme' do
    context 'with blank input' do
      it 'creates only an \'index.html\' file' do
        store = Dockmaster::DocParser.parse_string('', Dockmaster::Store.new(nil, :none, ''))

        Dockmaster::Output.start_processing(store)

        entries = Dir["#{Dockmaster::CONFIG[:output]}/*.html"]

        expect(entries).to include("#{Dockmaster::CONFIG[:output]}/index.html")
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

        output = Dockmaster::CONFIG[:output]

        expect(entries).to include("#{output}/index.html")
        expect(entries).to include("#{output}/Test/TestClass.html")
        expect(entries).to include("#{output}/Test.html")
      end
    end
  end
end
