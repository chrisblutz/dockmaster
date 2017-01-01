RSpec.describe Dockmaster::CLI do
  context 'with --debug option' do
    it 'puts Dockmaster into debug mode' do
      args = ['--debug']
      Dockmaster::CLI.new(args)

      expect(Dockmaster.debug?).to eq(true)
    end
  end

  context 'with -d short option' do
    it 'puts Dockmaster into debug mode' do
      args = ['-d']
      Dockmaster::CLI.new(args)

      expect(Dockmaster.debug?).to eq(true)
    end
  end

  describe '#execute' do
    context 'when building is enabled' do
      it 'builds documentation correctly' do
        old_output = Dockmaster::CONFIG[:output]
        Dockmaster::CONFIG[:output] = "../../../#{old_output}"
        Dir.chdir('spec/files/cli_test') do
          cli = Dockmaster::CLI.new([])
          cli.execute

          Dockmaster::CONFIG[:output] = old_output

          entries = Dir["../../../#{Dockmaster::CONFIG[:output]}/**/*.html"]

          expect(entries).to include("../../../#{Dockmaster::CONFIG[:output]}/index.html")
          expect(entries).to include("../../../#{Dockmaster::CONFIG[:output]}/TestFiles.html")
          expect(entries).to include("../../../#{Dockmaster::CONFIG[:output]}/TestFiles/TestClass.html")
        end
      end
    end
  end
end
