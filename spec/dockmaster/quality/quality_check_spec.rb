require 'dockmaster/quality/criteria'
require 'dockmaster/quality/quality_check'

RSpec.describe Dockmaster::QualityCheck do
  describe '.check' do
    context 'with no documentation' do
      it 'evaluates the documentation to grade 0' do
        mod_store = Dockmaster::Store.new(nil, :module, :TestModule)
        mod_store.docs = Dockmaster::Docs.new('', {})
        class_store = Dockmaster::Store.new(mod_store, :class, :TestClass)
        class_store.docs = Dockmaster::Docs.new('', {})
        field_data = Dockmaster::Data.new('', '<none>', nil, 0, false)
        field_data.docs = Dockmaster::Docs.new('', {})
        class_store.data_type(:instance_field)
        class_store.data[:instance_field] = { test_field: field_data }
        method_data = Dockmaster::Data.new('', '<none>', nil, 0, false, [:test_arg])
        method_data.docs = Dockmaster::Docs.new('', {})
        class_store.data_type(:instance_method)
        class_store.data[:instance_method] = { test_method: method_data }

        mod_store.children << class_store

        Dockmaster::QualityCheck.check(mod_store)

        Dockmaster::QualityCheck.criteria.each do |c|
          expect(c.evaluate).to eq(0)
        end
      end
    end

    context 'with full documentation' do
      it 'evaluates the documentation to grade 3' do
        mod_store = Dockmaster::Store.new(nil, :module, :TestModule)
        mod_store.docs = Dockmaster::Docs.new('Test description', {})
        class_store = Dockmaster::Store.new(mod_store, :class, :TestClass)
        class_store.docs = Dockmaster::Docs.new('Test description', {})
        field_data = Dockmaster::Data.new('', '<none>', nil, 0, false)
        field_data.docs = Dockmaster::Docs.new('Test description', {})
        class_store.data_type(:instance_field)
        class_store.data[:instance_field] = { test_field: field_data }
        method_data = Dockmaster::Data.new('', '<none>', nil, 0, false, [:test_arg])
        params = { test_arg: 'Param' }
        method_data.docs = Dockmaster::Docs.new('Test description', return: 'Return', params: params)
        class_store.data_type(:instance_method)
        class_store.data[:instance_method] = { test_method: method_data }

        mod_store.children << class_store

        Dockmaster::QualityCheck.check(mod_store)

        Dockmaster::QualityCheck.criteria.each do |c|
          expect(c.evaluate).to eq(3)
        end
      end
    end
  end
end
