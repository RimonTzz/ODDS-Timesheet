class TimesheetsController < ApplicationController
  include Devise::Controllers::Helpers
  include ApplicationHelper
  before_action :authenticate_user!

  def index
    @timesheets = current_user.admin? ? Timesheet.all : current_user.timesheets
    @user_projects = current_user.user_projects.includes(:project)
    @months = month_options
    @selected_month = params[:month] || Date.today.month
  end

  def new
    @user_projects = current_user.user_projects.includes(:project)
    @months = month_options
    @selected_month = params[:month] || session[:selected_month] || Date.today.month

    # ถ้าไม่มี user_project_id ที่เลือก ให้ใช้ตัวที่น้อยที่สุด
    @selected_user_project_id = params[:user_project_id] || session[:selected_user_project_id]
    if @selected_user_project_id.blank? && @user_projects.any?
      @selected_user_project_id = @user_projects.first.id
    end

    if @selected_user_project_id.present?
      @user_project = UserProject.find(@selected_user_project_id)
      @start_date = Date.new(Date.today.year, @selected_month.to_i, 1)
      @end_date = @start_date.end_of_month
      @timesheet_days = (@start_date..@end_date).to_a
      @timesheet = Timesheet.new

      # ดึงข้อมูล timesheet ที่มีอยู่
      @existing_timesheets = Timesheet.where(
        user_project: @user_project,
        date: @start_date..@end_date
      ).index_by(&:date)
    end
  end

  def create
    user_project = UserProject.find(params[:user_project_id])
    month = params[:month].to_i
    start_date = Date.new(Date.today.year, month, 1)
    end_date = start_date.end_of_month
    success = true

    ActiveRecord::Base.transaction do
      (start_date..end_date).each do |date|
        timesheet_data = params[:timesheet][date.day.to_s]
        if timesheet_data.present? && timesheet_data[:check_in].present? && timesheet_data[:check_out].present?
          # หา timesheet ที่มีอยู่หรือสร้างใหม่
          timesheet = Timesheet.find_or_initialize_by(
            user_project: user_project,
            date: date
          )

          # อัพเดทข้อมูล
          timesheet.assign_attributes(
            check_in: timesheet_data[:check_in],
            check_out: timesheet_data[:check_out],
            work_description: timesheet_data[:description],
            work_status: timesheet_data[:work_status].to_i
          )

          unless timesheet.save
            success = false
            raise ActiveRecord::Rollback
          end
        end
      end
    end

    if success
      # เก็บค่าไว้ใน session
      session[:selected_user_project_id] = user_project.id
      session[:selected_month] = month
      redirect_to new_timesheet_path(user_project_id: user_project.id, month: month), notice: "Timesheet was successfully saved."
    else
      redirect_to new_timesheet_path(user_project_id: user_project.id, month: month), alert: "Error saving timesheet. Please try again."
    end
  end

  def data
    user_project = UserProject.find(params[:user_project_id])
    timesheets = Timesheet.where(user: user_project.user, project: user_project.project).where("extract(month from date) = ?", params[:month])

    render json: { timesheets: timesheets, work_statuses: Timesheet.work_statuses }
  end

  def export_pdf
    @timesheets = current_user.admin? ? Timesheet.all : current_user.timesheets
    respond_to do |format|
      format.pdf do
        pdf = TimesheetPdf.new(@timesheets)
        send_data pdf.render, filename: "timesheet.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def timesheet_data
    user_project_id = params[:user_project_id]
    month = params[:month].to_i
    user_project = current_user.user_projects.find(user_project_id)
    start_date = Date.new(Date.today.year, month, 1)
    end_date = start_date.end_of_month
    @timesheets = Timesheet.where(user: current_user, project: user_project.project, date: start_date..end_date)
    render json: { timesheets: @timesheets.map { |t| { date: t.date, check_in: t.check_in, check_out: t.check_out, work_status: t.work_status } } }
  end

  private

  def timesheet_params
    params.require(:timesheet).permit(:site_id, :project_id, :position, :work_date, :hours_worked, :work_description, :signature, :submitted_at)
  end
end
