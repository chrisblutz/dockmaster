require 'dockmaster/docs/docs'
require 'dockmaster/quality/criteria'
require 'dockmaster/quality/enforcers/field_enforcer'

RSpec.describe Dockmaster::FieldEnforcer do
  describe '#matches' do
    it 'matches :static_field, :instance_field, and :constant data' do
      expect(Dockmaster::FieldEnforcer.matches(:static_field)).to eq(true)
      expect(Dockmaster::FieldEnforcer.matches(:instance_field)).to eq(true)
      expect(Dockmaster::FieldEnforcer.matches(:constant)).to eq(true)
    end
  end

  describe '#check' do
    context 'with description present' do
      it 'evaluates the documentation to grade 3' do
        data = Dockmaster::Data.new('', '<none>', nil, 0, false)
        data.docs = Dockmaster::Docs.new('Test description', {})

        parent = Dockmaster::Store.new(nil, :module, :TestModule)

        criteria = Dockmaster::Criteria.new
        criteria = Dockmaster::FieldEnforcer.check(:instance_field, :test_field, data, parent, criteria)

        expect(criteria.evaluate).to eq(3)
      end
    end

    context 'without description present' do
      it 'evaluates the documentation to grade 0' do
        data = Dockmaster::Data.new('', '<none>', nil, 0, false)
        data.docs = Dockmaster::Docs.new('', {})

        parent = Dockmaster::Store.new(nil, :module, :TestModule)

        criteria = Dockmaster::Criteria.new
        criteria = Dockmaster::FieldEnforcer.check(:instance_field, :test_field, data, parent, criteria)

        expect(criteria.evaluate).to eq(0)
      end
    end
  end
end
