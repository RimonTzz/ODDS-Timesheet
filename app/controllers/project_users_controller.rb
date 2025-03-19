
class ProjectUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project,  only: [ :index, :new, :create, :destroy, :edit, :update ]
  before_action :set_user_project, only: [:edit, :update, :destroy]
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
    user = User.find_by(id: params[:user_id]) # ใช้ find_by เพื่อป้องกัน RecordNotFound
    @user_project = @project.user_projects.new(user: user, position: params[:user_project][:position])

    if @user_project.save
      redirect_to project_users_path(@project), notice: "เพิ่ม #{user.email} ในตำแหน่ง #{@user_project.position.titleize} เข้าสู่โปรเจ็คแล้ว"
    else
      @available_users = User.where.not(id: @project.users.pluck(:id))
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    Rails.logger.debug "Params in edit action: #{params.inspect}"
  end

  def update
    if @user_project.update(user_project_params)
      redirect_to project_users_path(@project), notice: "#{@user_project.user.email} ได้รับการอัปเดตตำแหน่งแล้ว"
    else
      render :edit, status: :unprocessable_entity
    end
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

  def user_project_params
    params.require(:user_project).permit(:position)
  end

  def set_user_project
    @user_project = UserProject.find_by(user_id: params[:id], project: @project)
    unless @user_project
      flash[:alert] = "ไม่พบข้อมูลผู้ใช้ในโปรเจ็ค"
      redirect_to project_users_path(@project)
    end
  end
end

