class ProjectUsersController < ApplicationController
  before_action :set_project, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @project_users = @project.users
    @available_users = User.where.not(id: @project_users.pluck(:id))
  end

  def new
    @available_users = User.where.not(id: @project.users.pluck(:id))
  end

  def create
    @user_project = UserProject.new(
      project_id: params[:project_id],
      user_id: params[:user_id],
      position: params[:position]
    )

    respond_to do |format|
      if @user_project.save
        format.turbo_stream { success_turbo_stream("Member was successfully added.", project_users_path(@project)) }
        format.html { redirect_to project_users_path(@project), notice: 'Member was successfully added.' }
      else
        format.turbo_stream { error_turbo_stream("Failed to add member.") }
        format.html { render :new }
      end
    end
  end

  def edit
    @user_project = UserProject.find_by(user_id: params[:id], project_id: @project.id)
  end

  def update
    @user_project = UserProject.find_by(user_id: params[:id], project_id: @project.id)
  
    respond_to do |format|
      if @user_project.update(user_project_params)
        format.turbo_stream { success_turbo_stream("Member was successfully updated.", project_users_path(@project)) }
        format.html { redirect_to project_users_path(@project), notice: "Member was successfully updated." }
      else
        format.turbo_stream { error_turbo_stream("Failed to update member.") }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end
  
  

  def destroy
    @user_project = UserProject.find(params[:id]) # <-- ใช้ id ของ user_project
    @user_project.destroy
    redirect_to project_users_path(@project), notice: 'Member was successfully removed.'
  end
  

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def user_project_params
    params.require(:user_project).permit(:position)
  end
end
