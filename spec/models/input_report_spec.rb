require 'rails_helper'

RSpec.describe InputReport, type: :model do
  describe 'validaciones' do
    it { should belong_to(:user) }
    it { should belong_to(:output_report) }
    it { should have_many(:input_report_stocks) }
    
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:user) }
  end

  describe '#approve!' do
    let(:input_report) { create(:input_report) }

    context 'cuando es válido' do
      it 'cambia el estado a approved' do
        input_report.approve!
        expect(input_report.status).to eq('approved')
      end
    end

    context 'cuando ya está aprobado' do
      before { input_report.update(status: 'approved') }

      it 'lanza un error' do
        expect { input_report.approve! }.to raise_error(StandardError)
      end
    end
  end
end 