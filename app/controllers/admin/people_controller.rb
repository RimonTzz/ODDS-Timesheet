class Admin::PeopleController < ApplicationController
  before_action :authenticate_user!
  before_action :current_user_is_super_admin?
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.all
  end

  def edit
    @sites = Site.all # ดึงรายชื่อ Sites
    @projects = Project.all # ดึงรายชื่อ Projects
    @roles = User.roles.keys # ดึงรายชื่อ Roles จาก Enum (ถ้ามี)
    @user_projects = @user.user_projects.includes(:project) # ดึง Projects ที่ User นี้อยู่
  end

  def update
    old_role = @user.role
  
    respond_to do |format|
      if @user.update(user_params)
        message = "User #{@user.first_name} was successfully updated."
        if old_role != @user.role
          message += " Role changed from #{old_role.titleize} to #{@user.role.titleize}."
        end
  
        format.turbo_stream { success_turbo_stream(message, admin_people_path) }
        format.html { redirect_to admin_people_path, notice: message }
      else
        @sites = Site.all
        @projects = Project.all
        @roles = User.roles.keys
        @user_projects = @user.user_projects.includes(:project)
  
        format.turbo_stream { error_turbo_stream("Failed to update user.") }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end
  
  

  def destroy
    respond_to do |format|
      if @user.destroy
        message = "User #{@user.email} was successfully deleted."
        format.turbo_stream { success_turbo_stream(message, admin_people_path) }
        format.html { redirect_to admin_people_path, notice: message }
      else
        message = "Could not delete user #{@user.email}."
        format.turbo_stream { error_turbo_stream(message) }
        format.html { redirect_to admin_people_path, alert: message }
      end
    end
  end
  

  def assign_project
    @user = User.find(params[:id])
    project = Project.find(params[:project_id])
    unless @user.projects.include?(project)
      @user.projects << project
      redirect_to edit_admin_person_path(@user), notice: "add #{@user.email} to  #{project.project_name} "
    else
      redirect_to edit_admin_person_path(@user), alert: "#{@user.email} has in this #{project.project_name} already"
    end
  end

  def unassign_project
    @user = User.find(params[:id])
    project = Project.find(params[:project_id])
    @user.projects.delete(project)
    redirect_to edit_admin_person_path(@user), alert: "delete #{@user.email} from #{project.project_name} successfully"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:role, :site_id) # อนุญาตให้แก้ไข role และ site_id (ตามต้องการ)
  end
end
