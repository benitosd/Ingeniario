class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_directive_access
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @search = User.search do
      fulltext params[:search] unless params[:search].blank?
      paginate page: params[:page] || 1, per_page: 10
      order_by :code, :desc
    end
    @users = @search.results
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.directive = calculate_directive_bits

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'Usuario creado correctamente.' }
        format.turbo_stream { redirect_to users_path, notice: 'Usuario creado correctamente.' }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "user_form",
            partial: "form",
            locals: { user: @user }
          )
        }
      end
    end
  end

  def edit
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    @user.directive = calculate_directive_bits

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'Usuario actualizado correctamente.' }
        format.turbo_stream { redirect_to users_path, notice: 'Usuario actualizado correctamente.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "user_form",
            partial: "form",
            locals: { user: @user }
          )
        }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'Usuario eliminado correctamente.' }
      format.turbo_stream { redirect_to users_url, notice: 'Usuario eliminado correctamente.' }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :code)
  end

  def calculate_directive_bits
    return 0 if params[:user][:directive_bits].blank?
    params[:user][:directive_bits].map(&:to_i).sum
  end

  def check_directive_access
    unless current_user.has_directive?(Directives::EDIT_USER)
      flash[:alert] = "No tienes permiso para acceder a esta sección."
      redirect_to root_path
    end
  end
end
