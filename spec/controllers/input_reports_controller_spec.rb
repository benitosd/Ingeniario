require 'rails_helper'

RSpec.describe InputReportsController, type: :controller do
  let(:user) { create(:user) }
  
  before { sign_in user }

  describe 'GET #index' do
    it 'retorna una respuesta exitosa' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    let(:output_report) { create(:output_report) }
    let(:valid_attributes) { 
      { 
        date: Date.current,
        output_report_id: output_report.id,
        notes: 'Test notes'
      }
    }

    context 'con atributos válidos' do
      it 'crea un nuevo informe' do
        expect {
          post :create, params: { input_report: valid_attributes }
        }.to change(InputReport, :count).by(1)
      end
    end
  end

  describe 'PATCH #approve' do
    let(:input_report) { create(:input_report) }

    it 'aprueba el informe' do
      patch :approve, params: { id: input_report.id }
      input_report.reload
      expect(input_report.status).to eq('approved')
    end
  end
end 