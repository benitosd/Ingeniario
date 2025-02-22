require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#has_directive?' do
    let(:user) { create(:user) }

    context 'cuando directive es nil' do
      before { user.directive = nil }

      it 'retorna false' do
        expect(user.has_directive?(Directives::EDIT_USER)).to be false
      end
    end

    context 'cuando tiene la directiva' do
      before { user.directive = Directives::EDIT_USER }

      it 'retorna true' do
        expect(user.has_directive?(Directives::EDIT_USER)).to be true
      end
    end

    context 'cuando no tiene la directiva' do
      before { user.directive = Directives::EDIT_ITEM }

      it 'retorna false' do
        expect(user.has_directive?(Directives::EDIT_USER)).to be false
      end
    end

    context 'cuando tiene múltiples directivas' do
      before { user.directive = Directives::EDIT_USER | Directives::EDIT_ITEM }

      it 'retorna true si tiene la directiva consultada' do
        expect(user.has_directive?(Directives::EDIT_USER)).to be true
        expect(user.has_directive?(Directives::EDIT_ITEM)).to be true
      end

      it 'retorna false si no tiene la directiva consultada' do
        expect(user.has_directive?(Directives::EDIT_WAREHOUSE)).to be false
      end
    end
  end
end 