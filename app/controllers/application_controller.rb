class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_user_is_admin?
  helper_method :current_user_is_super_admin?

  def current_user_is_admin?
    current_user&.admin? || current_user&.super_admin?
  end

  def current_user_is_super_admin?
    current_user&.super_admin?
  end

  def authorize_admin! #access when admin and superadmin
    return if current_user_is_admin?

    flash[:alert] = "คุณไม่มีสิทธิ์เข้าถึงส่วนนี้"
    redirect_to root_path
  end

  def authorize_super_admin! #just super admin allow
    return if current_user_is_super_admin?

    flash[:alert] = "คุณไม่มีสิทธิ์เข้าถึงส่วนนี้"
    redirect_to root_path
  end

  def authorize_not_user!
    return unless current_user # ป้องกันกรณี current_user เป็น nil

    if current_user.role == "user"
      flash[:alert] = "คุณไม่มีสิทธิ์เข้าถึงส่วนนี้"
      redirect_to timesheets_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :phone_number, :email, :password, :password_confirmation ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :phone_number, :email, :password, :password_confirmation, :current_password ])
  end

  private

  def success_turbo_stream(message, redirect_path = nil)
    response = turbo_stream.update("flash", <<-HTML.strip_heredoc)
      <div class="alert-sticky" id="alert-message">
        <div class="alert-container alert-success">
          <div class="alert-flex">
            <div class="alert-icon alert-icon-success">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-5 w-5">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="alert-content">
              <p class="alert-text alert-text-success">#{message}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <script>
      (() => {
        const alert = document.getElementById('alert-message');
        if (alert) {
          setTimeout(() => {
            alert.classList.add('fade-out');
            setTimeout(() => {
              alert.remove();
              #{redirect_path ? "window.location.href = '#{redirect_path}';" : ""}
            }, 500);
          }, 1000);
        }
      })();
    </script>
  HTML
  
  render turbo_stream: response
end

  def error_turbo_stream(message)
    render turbo_stream: turbo_stream.update("flash", <<-HTML.strip_heredoc)
      <div class="alert-sticky" id="alert-message">
        <div class="alert-container alert-error">
          <div class="alert-flex">
            <div class="alert-icon alert-icon-error">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="h-5 w-5">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="alert-content">
              <p class="alert-text alert-text-error">#{message}</p>
            </div>
          </div>
        </div>
      </div>
      <script>
        (() => {
          const alert = document.getElementById('alert-message');
          if (alert) {
            setTimeout(() => {
              alert.classList.add('fade-out');
              setTimeout(() => {
                alert.remove();
              }, 500);
            }, 3000);
          }
        })();
      </script>
    HTML
  end
end
