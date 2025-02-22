require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_attributes) {
    { email: 'test@example.com', password: 'password123', code: 'USR001' }
  }

  let(:invalid_attributes) {
    { email: '', password: '' }
  }

  let(:admin_user) { create(:user, directive: Directives::EDIT_USER) }
  let(:regular_user) { create(:user, directive: Directives::EDIT_ITEM) }

  describe 'acceso a rutas' do
    context 'usuario sin directiva EDIT_USER' do
      before { sign_in regular_user }

      it 'redirige al root path' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('No tienes permiso para acceder a esta sección.')
      end
    end
  end

  context 'usuario con directiva EDIT_USER' do
    before { sign_in admin_user }

    describe 'GET #index' do
      it 'retorna una respuesta exitosa' do
        get :index
        expect(response).to be_successful
      end
    end

    describe 'POST #create' do
      context 'con atributos válidos' do
        it 'crea un nuevo usuario' do
          expect {
            post :create, params: { user: valid_attributes }
          }.to change(User, :count).by(1)
        end

        it 'redirige a la lista de usuarios' do
          post :create, params: { user: valid_attributes }
          expect(response).to redirect_to(users_path)
        end

        it 'asigna las directivas correctamente' do
          post :create, params: { 
            user: valid_attributes.merge(directive_bits: [Directives::EDIT_ITEM.to_s]) 
          }
          expect(User.last.has_directive?(Directives::EDIT_ITEM)).to be true
        end
      end

      context 'con atributos inválidos' do
        it 'no crea un nuevo usuario' do
          expect {
            post :create, params: { user: invalid_attributes }
          }.to_not change(User, :count)
        end

        it 'renderiza el formulario new' do
          post :create, params: { user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe 'PATCH #update' do
      let!(:user) { create(:user) }

      context 'con atributos válidos' do
        it 'actualiza el usuario' do
          patch :update, params: { 
            id: user.id, 
            user: { email: 'new@example.com' } 
          }
          user.reload
          expect(user.email).to eq('new@example.com')
        end

        it 'actualiza las directivas' do
          patch :update, params: { 
            id: user.id, 
            user: { directive_bits: [Directives::EDIT_ITEM.to_s] } 
          }
          user.reload
          expect(user.has_directive?(Directives::EDIT_ITEM)).to be true
        end
      end

      context 'con atributos inválidos' do
        it 'no actualiza el usuario' do
          original_email = user.email
          patch :update, params: { 
            id: user.id, 
            user: invalid_attributes 
          }
          user.reload
          expect(user.email).to eq(original_email)
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:user) { create(:user) }

      it 'elimina el usuario' do
        expect {
          delete :destroy, params: { id: user.id }
        }.to change(User, :count).by(-1)
      end

      it 'redirige a la lista de usuarios' do
        delete :destroy, params: { id: user.id }
        expect(response).to redirect_to(users_path)
      end
    end
  end
end 