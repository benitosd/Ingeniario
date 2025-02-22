require 'rails_helper'

RSpec.describe "Input Reports", type: :system do
  let(:user) { create(:user) }
  
  before do
    driven_by(:rack_test)
    sign_in user
  end

  describe 'creación de informe' do
    it 'crea un nuevo informe' do
      visit new_input_report_path
      fill_in 'Fecha', with: Date.current
      fill_in 'Notas', with: 'Test notes'
      click_button 'Guardar'
      
      expect(page).to have_content('Informe de entrada creado correctamente')
    end
  end

  describe 'aprobación de informe' do
    let!(:input_report) { create(:input_report) }

    it 'aprueba un informe' do
      visit input_report_path(input_report)
      click_button 'Aprobar'
      
      expect(page).to have_content('Informe de entrada aprobado correctamente')
    end
  end
end 