class TimesheetsController < ApplicationController
  include Devise::Controllers::Helpers
  include ApplicationHelper
  before_action :authenticate_user!
  before_action :set_user_projects
  before_action :set_timesheet, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_not_user!, only: [ :edit, :update, :destroy ]

  def index
    @timesheets = current_user.timesheets.includes(:user_project)
    @months = month_options
    # ถ้าไม่มี project ให้ใช้ค่าเริ่มต้น
    @selected_user_project_id = params[:user_project_id]
    unless @selected_user_project_id
      @selected_user_project_id = @user_projects.order(:id).first&.id
    end

    @user_project = UserProject.find_by(id: @selected_user_project_id)

    # กำหนดค่า month
    @selected_month = if params[:month].present?
      begin
        # ตรวจสอบว่า month ที่ส่งมาเป็นรูปแบบที่ถูกต้องหรือไม่
        if params[:month].match?(/\A\d{4}-\d{2}\z/)
          year, month = params[:month].split("-").map(&:to_i)
          Date.new(year, month, 1) # ทดสอบว่าสามารถสร้างวันที่ได้หรือไม่
          params[:month]
        else
          Time.current.strftime("%Y-%m")
        end
      rescue ArgumentError
        Time.current.strftime("%Y-%m")
      end
    else
      Time.current.strftime("%Y-%m")
    end

    if @user_project
      begin
        # สร้าง array ของวันที่ในเดือนที่เลือก
        year, month = @selected_month.split("-").map(&:to_i)
        @timesheet_days = (Date.new(year, month, 1)..Date.new(year, month, -1)).to_a

        # ดึงข้อมูล timesheet ที่มีอยู่แล้ว
        @existing_timesheets = @user_project.timesheets
                                        .where(date: @timesheet_days)
                                        .index_by(&:date)
      rescue ArgumentError
        # ถ้าเกิด error ให้ใช้เดือนปัจจุบัน
        current_date = Time.current
        @selected_month = current_date.strftime("%Y-%m")
        @timesheet_days = (Date.new(current_date.year, current_date.month, 1)..Date.new(current_date.year, current_date.month, -1)).to_a
        @existing_timesheets = @user_project.timesheets
                                        .where(date: @timesheet_days)
                                        .index_by(&:date)
      end
    end
  end

  def show
  end

  def new
    @user_project = UserProject.find_by(id: params[:user_project_id])
    @months = month_options

    # ถ้าไม่มี project ให้ใช้ค่าเริ่มต้น
    unless @user_project
      @user_project = @user_projects.order(:id).first
    end

    # กำหนดค่า month
    @selected_month = if params[:month].present?
      begin
        # ตรวจสอบว่า month ที่ส่งมาเป็นรูปแบบที่ถูกต้องหรือไม่
        if params[:month].match?(/\A\d{4}-\d{2}\z/)
          year, month = params[:month].split("-").map(&:to_i)
          Date.new(year, month, 1) # ทดสอบว่าสามารถสร้างวันที่ได้หรือไม่
          params[:month]
        else
          Time.current.strftime("%Y-%m")
        end
      rescue ArgumentError
        Time.current.strftime("%Y-%m")
      end
    else
      Time.current.strftime("%Y-%m")
    end

    if @user_project
      begin
        # สร้าง array ของวันที่ในเดือนที่เลือก
        year, month = @selected_month.split("-").map(&:to_i)
        @timesheet_days = (Date.new(year, month, 1)..Date.new(year, month, -1)).to_a

        # ดึงข้อมูล timesheet ที่มีอยู่แล้ว
        @existing_timesheets = @user_project.timesheets
                                          .where(date: @timesheet_days)
                                          .index_by(&:date)
      rescue ArgumentError
        # ถ้าเกิด error ให้ใช้เดือนปัจจุบัน
        current_date = Time.current
        @selected_month = current_date.strftime("%Y-%m")
        @timesheet_days = (Date.new(current_date.year, current_date.month, 1)..Date.new(current_date.year, current_date.month, -1)).to_a
        @existing_timesheets = @user_project.timesheets
                                          .where(date: @timesheet_days)
                                          .index_by(&:date)
      end
    end
  end

  def edit
  end

  def create
    @user_project = UserProject.find(timesheet_params[:user_project_id])
    @selected_month = params[:month]

    # สร้าง array ของวันที่ในเดือนที่เลือก
    year, month = @selected_month.split("-").map(&:to_i)
    @timesheet_days = (Date.new(year, month, 1)..Date.new(year, month, -1)).to_a

    # ดึงข้อมูล timesheet ที่มีอยู่แล้ว
    @existing_timesheets = @user_project.timesheets
                                    .where(date: @timesheet_days)
                                    .index_by(&:date)

    # ตรวจสอบว่ามีการส่งข้อมูลมาหรือไม่
    if params[:timesheet].present?
      success = true
      @user_project.transaction do
        params[:timesheet].each do |day, data|
          next if data[:check_in].blank? && data[:check_out].blank? && data[:work_status].blank? && data[:description].blank?

          date = Date.new(year, month, day.to_i)

          # ตรวจสอบว่าเป็นวันหยุดหรือไม่
          if Holiday.is_holiday?(date)
            flash.now[:alert] = "ไม่สามารถบันทึกข้อมูลในวันหยุดได้"
            success = false
            break
          end

          timesheet = @user_project.timesheets.find_or_initialize_by(date: date)
          timesheet.assign_attributes(
            check_in: data[:check_in],
            check_out: data[:check_out],
            work_status: data[:work_status],
            work_description: data[:description]
          )

          unless timesheet.save
            success = false
            break
          end
        end
      end

      if success
        redirect_to timesheets_path(user_project_id: @user_project.id, month: @selected_month), notice: "บันทึกข้อมูลสำเร็จ"
      else
        render :index, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "กรุณากรอกข้อมูลอย่างน้อย 1 วัน"
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @timesheet.update(timesheet_params)
      redirect_to @timesheet, notice: "อัพเดทข้อมูลสำเร็จ"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @timesheet.destroy
    redirect_to timesheets_path, notice: "ลบข้อมูลสำเร็จ"
  end

  def data
    user_project = UserProject.find(params[:user_project_id])
    month = params[:month].to_i
    start_date = Date.new(Date.today.year, month, 1)
    end_date = start_date.end_of_month

    @timesheets = Timesheet.where(user_project: user_project, date: start_date..end_date)
    render json: @timesheets
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

  def set_user_projects
    @user_projects = current_user.user_projects.includes(:project)
  end

  def set_timesheet
    @timesheet = Timesheet.find(params[:id])
  end

  def timesheet_params
    params.require(:timesheet).permit(:user_project_id, :date, :check_in, :check_out, :work_status, :notes)
  end

  def authorize_not_user!
    unless current_user.admin?
      redirect_to timesheets_path, alert: "คุณไม่มีสิทธิ์ในการดำเนินการนี้"
    end
  end
end
