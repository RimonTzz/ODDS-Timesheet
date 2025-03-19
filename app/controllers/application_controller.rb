class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :authenticate_user!
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
end
