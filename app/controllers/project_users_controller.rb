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

    if @user_project.save
      redirect_to project_users_path(@project), notice: 'Member was successfully added.'
    else
      render :new
    end
  end

  def edit
    @user_project = UserProject.find_by(user_id: params[:id], project_id: @project.id)
  end

  def update
    @user_project = UserProject.find_by(user_id: params[:id], project_id: @project.id)
    if @user_project.update(position: params[:position])
      redirect_to project_users_path(@project), notice: 'Member was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user_project = UserProject.find_by(user_id: params[:id], project_id: @project.id)
    @user_project.destroy
    redirect_to project_users_path(@project), notice: 'Member was successfully removed.'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
