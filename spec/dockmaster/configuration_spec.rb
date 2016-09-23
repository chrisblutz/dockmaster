RSpec.describe Dockmaster::Configuration do
  context 'no title defined' do
    it 'returns the default title format' do
      hash = {}
      config = Dockmaster::Configuration.new(hash)

      expect(config.title).to eq('dockmaster Documentation')
    end
  end
end
