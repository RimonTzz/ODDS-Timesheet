class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: [:update]

  def edit
    super
  end

  def update
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
      params[:user].delete(:current_password)
    end

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update(account_update_params.except(:current_password))
      bypass_sign_in resource, scope: resource_name
      flash[:notice] = "Profile updated successfully."
      redirect_to after_update_path_for(resource)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def check_email
    email = params[:email]
    exists = User.exists?(email: email)
    render json: { exists: exists }
  end

  protected

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone_number])
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  private

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :password, :password_confirmation, :current_password)
  end
end 