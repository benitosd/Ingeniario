require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'validaciones' do
    it { should belong_to(:item) }
    it { should belong_to(:section) }
    it { should have_many(:stock_movements) }
    
    it { should validate_presence_of(:item) }
    it { should validate_presence_of(:section) }
  end

  describe '#to_s' do
    let(:item) { create(:item, name: 'Test Item') }
    let(:stock) { create(:stock, item: item) }

    it 'retorna el nombre del item' do
      expect(stock.to_s).to eq('Test Item')
    end
  end
end 