
class ProjectUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project,  only: [ :index, :new, :create, :destroy ]
  before_action :authorize_admin!

  def index
    @project_users = @project.users
    @available_users = User.where.not(id: @project_users.pluck(:id))
  end

  def new
    @user_project = @project.user_projects.new
    @available_users = User.where.not(id: @project.users.pluck(:id))
  end

  def create
    user = User.find(params[:user_id]) # รับ user_id จาก Form
    @project.users << user
    redirect_to project_users_path(@project), notice: "เพิ่ม #{user.email} เข้าสู่โปรเจ็คแล้ว"
  end

  def destroy
    user = User.find(params[:id])
    @project.users.delete(user)
    redirect_to project_users_path(@project), alert: "ลบ #{user.email} ออกจากโปรเจ็คแล้ว"
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end

