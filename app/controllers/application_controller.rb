class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:code,:password,:encrypted_password, :password_confirmation,:remember_me)}
        
     end


end
