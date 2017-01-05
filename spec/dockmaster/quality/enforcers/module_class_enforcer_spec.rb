require 'dockmaster/docs/docs'
require 'dockmaster/quality/criteria'
require 'dockmaster/quality/enforcers/module_class_enforcer'

RSpec.describe Dockmaster::ModuleClassEnforcer do
  describe '#matches' do
    it 'matches :module and :class stores' do
      expect(Dockmaster::ModuleClassEnforcer.matches(:module)).to eq(true)
      expect(Dockmaster::ModuleClassEnforcer.matches(:class)).to eq(true)
    end
  end

  describe '#check' do
    context 'with description present' do
      it 'evaluates the documentation to grade 3' do
        store = Dockmaster::Store.new(nil, :module, :TestModule)
        store.docs = Dockmaster::Docs.new('Test description', {})

        criteria = Dockmaster::Criteria.new
        criteria = Dockmaster::ModuleClassEnforcer.check(store, criteria)

        expect(criteria.evaluate).to eq(3)
      end
    end

    context 'without description present' do
      it 'evaluates the documentation to grade 0' do
        store = Dockmaster::Store.new(nil, :module, :TestModule)
        store.docs = Dockmaster::Docs.new('', {})

        criteria = Dockmaster::Criteria.new
        criteria = Dockmaster::ModuleClassEnforcer.check(store, criteria)

        expect(criteria.evaluate).to eq(0)
      end
    end
  end
end
