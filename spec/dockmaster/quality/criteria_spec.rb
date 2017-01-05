require 'dockmaster/quality/criteria'

RSpec.describe Dockmaster::Criteria do
  describe '#name' do
    context 'with defined name' do
      it 'saves the scope name' do
        criteria = Dockmaster::Criteria.new
        criteria.define_scope('test')
        expect(criteria.name).to eq('test')
      end
    end

    context 'with no defined name' do
      it 'returns the placeholder name' do
        criteria = Dockmaster::Criteria.new
        expect(criteria.name).to eq('UNDEFINED SCOPE NAME')
      end
    end
  end

  describe '#define_new' do
    it 'registers a new criterion' do
      criteria = Dockmaster::Criteria.new
      criteria.define_new(:test, 'Description')
      expect(criteria.internal_desc[:test]).to eq('Description')
    end
  end

  context 'with 1 documentation item and 1 missing' do
    it 'evaluates the documentation to grade 0' do
      criteria = Dockmaster::Criteria.new
      criteria.set(:test1, false)
      expect(criteria.evaluate).to eq(0)
    end
  end

  context 'with no documentation items' do
    it 'evaluates the documentation to grade 0' do
      criteria = Dockmaster::Criteria.new
      expect(criteria.evaluate).to eq(0)
    end
  end

  context 'with no missing documentation items' do
    it 'evaluates the documentation to grade 3' do
      criteria = Dockmaster::Criteria.new
      criteria.set(:test1, true)
      criteria.set(:test2, true)
      criteria.set(:test3, true)
      expect(criteria.evaluate).to eq(3)
    end
  end

  context 'with 1 missing documentation item' do
    it 'evaluates the documentation to grade 2' do
      criteria = Dockmaster::Criteria.new
      criteria.set(:test1, false)
      criteria.set(:test2, true)
      expect(criteria.evaluate).to eq(2)
    end
  end

  context 'with 2 missing documentation items' do
    it 'evaluates the documentation to grade 1' do
      criteria = Dockmaster::Criteria.new
      criteria.set(:test1, false)
      criteria.set(:test2, false)
      criteria.set(:test3, true)
      expect(criteria.evaluate).to eq(1)
    end
  end

  context 'with 3 missing documentation items' do
    it 'evaluates the documentation to grade 0' do
      criteria = Dockmaster::Criteria.new
      criteria.set(:test1, false)
      criteria.set(:test2, false)
      criteria.set(:test3, false)
      criteria.set(:test4, true)
      expect(criteria.evaluate).to eq(0)
    end
  end
end
