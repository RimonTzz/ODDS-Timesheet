class Admin::PeopleController < ApplicationController
  before_action :authenticate_user!
  before_action :current_user_is_super_admin?

  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
    @sites = Site.all # ดึงรายชื่อ Sites
    @projects = Project.all # ดึงรายชื่อ Projects
    @roles = User.roles.keys # ดึงรายชื่อ Roles จาก Enum (ถ้ามี)
    @user_projects = @user.user_projects.includes(:project) # ดึง Projects ที่ User นี้อยู่
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_people_path, notice: "อัปเดตข้อมูลผู้ใช้ #{@user.email} แล้ว"
    else
      @sites = Site.all
      @projects = Project.all
      @roles = User.roles.keys
      @user_projects = @user.user_projects.includes(:project)
      render :edit, status: :unprocessable_entity
    end
  end

  def assign_project
    @user = User.find(params[:id])
    project = Project.find(params[:project_id])
    unless @user.projects.include?(project)
      @user.projects << project
      redirect_to edit_admin_person_path(@user), notice: "เพิ่ม #{@user.email} เข้าสู่โปรเจ็ค #{project.project_name} แล้ว"
    else
      redirect_to edit_admin_person_path(@user), alert: "#{@user.email} อยู่ในโปรเจ็ค #{project.project_name} แล้ว"
    end
  end

  def unassign_project
    @user = User.find(params[:id])
    project = Project.find(params[:project_id])
    @user.projects.delete(project)
    redirect_to edit_admin_person_path(@user), alert: "ลบ #{@user.email} ออกจากโปรเจ็ค #{project.project_name} แล้ว"
  end

  private

  def user_params
    params.require(:user).permit(:role, :site_id) # อนุญาตให้แก้ไข role และ site_id (ตามต้องการ)
  end
end
