require 'dockmaster/docs/docs'
require 'dockmaster/quality/criteria'
require 'dockmaster/quality/enforcers/method_enforcer'

RSpec.describe Dockmaster::MethodEnforcer do
  describe '#matches' do
    it 'matches :static_method and :instance_method data' do
      expect(Dockmaster::MethodEnforcer.matches(:static_method)).to eq(true)
      expect(Dockmaster::MethodEnforcer.matches(:instance_method)).to eq(true)
    end
  end

  describe '#check' do
    context 'with description, parameter descriptions, and return value description present' do
      it 'evaluates the documentation to grade 3' do
        data = Dockmaster::Data.new('', '<none>', nil, 0, false, [:test_arg])
        params = { test_arg: 'Test' }
        data.docs = Dockmaster::Docs.new('Test description', return: 'Return', params: params)

        parent = Dockmaster::Store.new(nil, :module, :TestModule)

        criteria = Dockmaster::Criteria.new
        criteria = Dockmaster::MethodEnforcer.check(:instance_method, :test_method, data, parent, criteria)

        expect(criteria.evaluate).to eq(3)
      end
    end

    context 'with description and return value description, without any parameters' do
      it 'evaluates the documentation to grade 3' do
        data = Dockmaster::Data.new('', '<none>', nil, 0, false, [])
        data.docs = Dockmaster::Docs.new('Test description', return: 'Return')

        parent = Dockmaster::Store.new(nil, :module, :TestModule)

        criteria = Dockmaster::Criteria.new
        criteria = Dockmaster::MethodEnforcer.check(:instance_method, :test_method, data, parent, criteria)

        expect(criteria.evaluate).to eq(3)
      end
    end
  end
end
